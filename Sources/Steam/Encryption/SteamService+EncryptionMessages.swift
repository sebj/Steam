//
//  SteamService+EncryptionMessages.swift
//
//  Copyright © 2021 Sebastian Jachec. All rights reserved.
//

import Foundation

extension SteamService {
    func handleEncryptionRequest(message: MessageProtocol) {
        guard let encryptionRequest = try? EncryptionRequest(data: message.payload) else {
            connection?.disconnect()
            return
        }

        guard encryptionRequest.universe == .public else {
            connection?.disconnect()
            return
        }

        guard let sessionKeyData = try? makeSessionEncryptionData() else {
            connection?.disconnect()
            return
        }

        let hmac = encryptionRequest.challenge
        guard let encryptedSessionKeyData = try? encryptSessionKey(plainKeyData: sessionKeyData.plainData, hmac: hmac) else {
            connection?.disconnect()
            return
        }

        let protocolVersion = UInt32(1).bytes.reversed()
        let sessionKeySize = UInt32(128).bytes.reversed()

        var data = Data()
        data.append(contentsOf: protocolVersion)
        data.append(contentsOf: sessionKeySize)
        data.append(encryptedSessionKeyData)
        data.append(contentsOf: encryptedSessionKeyData.crc32().bytes.reversed())
        data.append(contentsOf: UInt32(0).bytes.reversed())

        let message = Message(
            header: .init(messageType: .kEmsgChannelEncryptResponse),
            payload: data)

        encryption = .inProgress(sessionKeyData)

        send(message)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.connection?.disconnect()
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func handleEncryptionResult(message: MessageProtocol) {
        guard case let .inProgress(encryptionKey) = encryption else {
            return
        }

        let encryptionResult = EncryptionResult(data: message.payload)
        guard encryptionResult.result == .success else {
            connection?.disconnect()
            return
        }

        encryption = .encrypted(encryptionKey)

        connectionStatusSubject.send(.ready)
    }
}
