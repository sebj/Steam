//
//  SteamService.swift
//
//  Copyright © 2020-2021 Sebastian Jachec. All rights reserved.
//

import Combine
import Foundation
import Gzip

typealias ConnectionFactory = (String, Int, DispatchQueue) -> ConnectionProtocol?

public final class SteamService {

    public let connectionStatus: AnyPublisher<ConnectionStatus, Never>

    /// A publisher that emits the friends list for the logged-in user.
    public let friends: AnyPublisher<[SteamFriend], Never>

    let connectionStatusSubject = PassthroughSubject<ConnectionStatus, Never>()
    private let friendsSubject = PassthroughSubject<[SteamFriend], Never>()

    let messages: AnyPublisher<MessageProtocol, Never>
    private let messagesSubject = PassthroughSubject<MessageProtocol, Never>()

    var session: Session = .none
    var encryption: SessionEncryption = .unencrypted
    private var heartbeat = Heartbeat.inactive

    var cancellables = Set<AnyCancellable>()
    var connection: ConnectionProtocol?

    private let queue = DispatchQueue(label: String(describing: SteamService.self))
    private let connectionFactory: ConnectionFactory

    public convenience init() {
        self.init(connectionFactory: NetworkConnection.init)
    }

    init(connectionFactory: @escaping ConnectionFactory) {
        self.connectionFactory = connectionFactory
        connectionStatus = connectionStatusSubject.share().eraseToAnyPublisher()
        messages = messagesSubject.share().eraseToAnyPublisher()
        friends = friendsSubject.share().eraseToAnyPublisher()
    }

    public enum ConnectionError: Error {
        case alreadyConnected
        case failedToCreateConnection
    }

    /// Establish a new connection to a given Steam server, if a connection is not already open.
    /// - Parameter server: The Steam server to connect to.
    /// - Returns: A publisher that emits `Void` when the connection has been established and is ready for requests to be sent,
    /// or a `ConnectionError` if the connection fails.
    public func connect(to server: SteamServer) -> AnyPublisher<Void, ConnectionError> {
        guard connection == nil else {
            return Fail(error: ConnectionError.alreadyConnected).eraseToAnyPublisher()
        }

        guard let connection = connectionFactory(server.host, server.port, queue) else {
            return Fail(error: ConnectionError.failedToCreateConnection).eraseToAnyPublisher()
        }

        self.connection = connection

        connection.status
            .filter { $0 == .disconnected }
            .sink { [weak self] _ in
                self?.didDisconnect()
            }
            .store(in: &cancellables)

        connection.data
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] data in
                    self?.receivedData(packet: data)
                })
            .store(in: &cancellables)

        connection.connect()

        let connectionFailed = connection.status
            .first()
            .filter { $0 == .disconnected }
            .tryMap { _ in
                throw ConnectionError.failedToCreateConnection
            }
            .mapError { ($0 as? ConnectionError) ?? ConnectionError.failedToCreateConnection }

        let connectionReady = messages
            .first(where: { $0.type == .kEmsgChannelEncryptResult })
            .map { _ in () }
            .setFailureType(to: ConnectionError.self)

        return connectionFailed.merge(with: connectionReady)
            .first()
            .eraseToAnyPublisher()
    }

    private func didDisconnect() {
        cancellables.forEach { $0.cancel() }
        cancellables = []

        if case let .active(cancellable) = heartbeat {
            cancellable.cancel()
            heartbeat = .inactive
        }

        encryption = .unencrypted
        connection = nil
        connectionStatusSubject.send(.disconnected)
    }
}

// MARK: - Parse

extension SteamService {
    
    private func receivedData(packet: Data) {
        let messages = parseMessages(packet: packet)
        messages.forEach(parseMessage)
    }

    private func parseMessages(packet: Data) -> [Data] {
        var reader = MessageReader(packet: packet)

        let encryption: MessageReader.Encryption
        switch self.encryption {
        case let .encrypted(encryptionKey):
            encryption = .encrypted(encryptionKey)
        default:
            encryption = .none
        }

        var messages = [Data]()
        while reader.canRead {
            guard let message = try? reader.readMessage(encryption: encryption) else {
                return messages
            }

            messages.append(message)
        }

        return messages
    }

    private func parseMessage(_ data: Data) {
        var reader = DataReader(data: data)

        let rawMessageType: UInt32 = reader.read()
        let messageType: EMsg?
        if rawMessageType.isProtobuf {
            messageType = EMsg(rawValue: Int(rawMessageType.withoutProtobufBit))
        } else {
            messageType = EMsg(rawValue: Int(rawMessageType))
        }

        guard let messageType = messageType else {
            print("\(String(describing: Self.self)) found unknown message type, raw value \(rawMessageType)")
            return
        }

        let message: MessageProtocol
        do {
            if
                [EMsg.kEmsgChannelEncryptRequest, EMsg.kEmsgChannelEncryptResponse, EMsg.kEmsgChannelEncryptResult]
                .contains(messageType)
            {
                message = try Message(data: data, isExtended: false)
            } else {
                if rawMessageType.isProtobuf {
                    message = try ProtobufMessage(data: data)
                } else {
                    message = try Message(data: data, isExtended: true)
                }
            }
        } catch {
            return
        }

        switch messageType {
        case .kEmsgChannelEncryptRequest:
            handleEncryptionRequest(message: message)

        case .kEmsgChannelEncryptResult:
            handleEncryptionResult(message: message)

        case .kEmsgMulti:
            handleMulti(message: message)

        case .kEmsgClientLogOnResponse:
            handleLogOnResponse(message: message)
            messagesSubject.send(message)

        case .kEmsgClientNewLoginKey:
            handleLoginKey(message: message)
            messagesSubject.send(message)

        case .kEmsgClientFriendsList:
            handleFriendsList(message: message)

        default:
            break
        }

        messagesSubject.send(message)
    }
}

// MARK: - Handle Message Types

extension SteamService {

    private func handleMulti(message: MessageProtocol) {
        guard let multiMessage = try? CMsgMulti(serializedData: message.payload) else {
            return
        }

        let data: Data

        if multiMessage.sizeUnzipped > 0 && !multiMessage.messageBody.isEmpty {
            guard
                let decompressedData = try? multiMessage.messageBody.gunzipped(),
                decompressedData.count == multiMessage.sizeUnzipped else {
                return
            }

            data = decompressedData
        } else {
            data = multiMessage.messageBody
        }

        var reader = DataReader(data: data)

        while reader.hasData {
            let messageSize: UInt32 = reader.read()

            if reader.canRead(Int(messageSize)) {
                parseMessage(reader.read(Int(messageSize)))
            } else {
                parseMessage(reader.readRemainingData())
            }
        }
    }

    private func handleLogOnResponse(message: MessageProtocol) {
        guard let response = try? CMsgClientLogonResponse(serializedData: message.payload) else {
            return
        }

        let result = SteamResult(rawValue: UInt32(response.eresult))

        switch result {
        case .tryAnotherServer, .serviceUnavailable:
            connection?.disconnect()
        case .success:
            if let steamIdentifier = message.steamIdentifier, let sessionIdentifier = message.sessionIdentifier {
                session = .loggedOn(sessionIdentifier: sessionIdentifier, steamIdentifier: steamIdentifier)
            }

            let heartbeatInterval = response.outOfGameHeartbeatSeconds
            startHeartbeat(interval: TimeInterval(heartbeatInterval))

        default:
            connection?.disconnect()
        }
    }

    private func handleLoginKey(message: MessageProtocol) {
        guard let response = try? CMsgClientNewLoginKey(serializedData: message.payload) else {
            return
        }

        var rawPayload = CMsgClientNewLoginKeyAccepted()
        rawPayload.uniqueID =  response.uniqueID

        guard let payload = try? rawPayload.serializedData() else {
            return
        }

        let message = ProtobufMessage(
            header: .init(messageType: .kEmsgClientNewLoginKeyAccepted),
            payload: payload)

        send(message)
            .sink()
            .store(in: &cancellables)
    }

    private func handleFriendsList(message: MessageProtocol) {
        guard let response = try? CMsgClientFriendsList(serializedData: message.payload) else {
            return
        }

        let friends = response.friends.compactMap { friend -> SteamFriend? in
            guard let identifier = SteamIdentifier(friend.ulfriendid), identifier.accountType == .individual else {
                return nil
            }

            guard let relationship = SteamFriend.Relationship(rawValue: friend.efriendrelationship) else {
                return nil
            }

            return SteamFriend(identifier: identifier, relationship: relationship)
        }

        friendsSubject.send(friends)
    }
}

// MARK: - Heartbeat

extension SteamService {

    private enum Heartbeat {
        case inactive
        case active(AnyCancellable)
    }

    private func startHeartbeat(interval: TimeInterval) {
        let cancellable = Timer.publish(every: interval, on: .main, in: .common)
            .flatMap { [weak self] _ -> AnyPublisher<Void, Never> in
                (try? self?.sendHeartbeat()) ?? Empty(completeImmediately: false).eraseToAnyPublisher()
            }
            .sink()

        heartbeat = .active(cancellable)
    }

    private func sendHeartbeat() throws -> AnyPublisher<Void, Never> {
        let payload = try CMsgClientHeartBeat().serializedData()

        let message = ProtobufMessage(
            header: .init(messageType: .kEmsgClientHeartBeat),
            payload: payload)

        return send(message)
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }
}

// MARK: -

public enum SteamUIMode: UInt32 {
    case desktop
    case bigPicture
    case mobile
    case web
}

extension SteamService {

    /// Set the logged in user's UI mode.
    /// This is typically shown as a small icon next to their name in the Steam friends list (phone, controller, etc.)
    public func setUIMode(_ uiMode: SteamUIMode)  -> AnyPublisher<Void, SendError> {
        guard case .encrypted = encryption else {
            return Fail(error: SendError.unencryptedConnection).eraseToAnyPublisher()
        }

        var request = CMsgClientUIMode()
        request.uimode = uiMode.rawValue

        let payload: Data
        do {
            payload = try request.serializedData()
        } catch {
            return Fail(error: SendError.failedToEncode(error)).eraseToAnyPublisher()
        }

        let message = ProtobufMessage(
            header: .init(messageType: .kEmsgClientCurrentUimode),
            payload: payload)

        return send(message)
    }

    func fetchUserInfo(
        userIdentifiers: [SteamIdentifier],
        info: UserInfo = [.playerName, .presence, .sourceID, .gameExtraInfo]) -> AnyPublisher<Void, SendError>
    {
        guard case .encrypted = encryption else {
            return Fail(error: SendError.unencryptedConnection).eraseToAnyPublisher()
        }

        var request = CMsgClientRequestFriendData()
        request.personaStateRequested = info.rawValue
        request.friends = userIdentifiers.map(\.rawValue)

        let payload: Data
        do {
            payload = try request.serializedData()
        } catch {
            return Fail(error: SendError.failedToEncode(error)).eraseToAnyPublisher()
        }

        let message = ProtobufMessage(
            header: .init(messageType: .kEmsgClientRequestFriendData),
            payload: payload)

        return send(message)
    }
}

extension SteamService {
    public enum ConnectionStatus {
        case ready
        case disconnected
    }

    enum Session {
        case none
        case loggedOn(sessionIdentifier: SessionIdentifier, steamIdentifier: UInt64)
    }
}
