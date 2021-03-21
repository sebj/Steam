//
//  MessageReader.swift
//
//  Copyright © 2021 Sebastian Jachec. All rights reserved.
//

import Foundation

struct MessageReader {

    enum Encryption {
        case none
        case encrypted(EncryptionData)
    }

    private var reader: DataReader

    init(packet: Data) {
        reader = DataReader(data: packet)
    }

    var canRead: Bool {
        let headerSize = MemoryLayout<UInt32>.size * 2
        return reader.remainingDataSize > headerSize
    }

    mutating func readMessage(encryption: Encryption) throws -> Data {
        guard canRead else {
            throw ReadError.noMoreMessages
        }

        let packet = try Packet(&reader)

        switch encryption {
        case let .encrypted(encryptionData):
            let messageBytes: [UInt8]
            do {
                messageBytes = try symmetricDecrypt(
                    packet.content,
                    key: encryptionData.plainData,
                    hmacSecret: encryptionData.hmac)
            } catch {
                throw ReadError.decryptionFailed(error)
            }

            return Data(messageBytes)
        case .none:
            return packet.content
        }
    }

    enum ReadError: Error {
        case decryptionFailed(Error)
        case noMoreMessages
    }
}
