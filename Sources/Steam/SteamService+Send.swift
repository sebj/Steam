//
//  SteamService+Send.swift
//  
//  Copyright © 2021 Sebastian Jachec. All rights reserved.
//

import Combine
import Foundation
import Network

extension SteamService {

    public enum SendError: Error {
        case disconnected
        case unencryptedConnection
        case failedToEncode(Error)
        case network(Error)
        case unknown
    }

    func send(_ message: ProtobufMessage) -> AnyPublisher<Void, SendError> {
        var populatedMessage = message

        if case let .loggedOn(sessionIdentifier, steamIdentifier) = session {
            populatedMessage.header.content.clientSessionid = sessionIdentifier
            populatedMessage.header.content.steamid = steamIdentifier
        }

        return send(populatedMessage as DataConvertible)
    }

    func send(_ dataConvertible: DataConvertible) -> AnyPublisher<Void, SendError> {
        guard let connection = connection else {
            return Fail(error: SendError.disconnected).eraseToAnyPublisher()
        }

        let data: Data
        do {
            data = try dataConvertible.asData()
        } catch {
            return Fail(error: SendError.failedToEncode(error)).eraseToAnyPublisher()
        }

        let contentBytes: [UInt8]

        switch encryption {
        case .unencrypted, .inProgress:
            contentBytes = data.bytes
        case let .encrypted(encryptionKey):
            do {
                contentBytes = try symmetricEncrypt(data, key: encryptionKey.plainData, hmacSecret: encryptionKey.hmac)
            } catch {
                return Fail(error: SendError.failedToEncode(error)).eraseToAnyPublisher()
            }
        }

        let packet = Packet(content: Data(contentBytes))
        let payload = packet.asData()

        return connection.send(payload)
            .mapError { error in
                switch error {
                case let .network(underlyingError):
                    return .network(underlyingError)
                case .unknown:
                    return .unknown
                }
            }
            .eraseToAnyPublisher()
    }
}
