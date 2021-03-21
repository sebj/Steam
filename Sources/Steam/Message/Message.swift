//
//  Message.swift
//
//  Copyright © 2020-2021 Sebastian Jachec. All rights reserved.
//

import Foundation

struct Message: MessageProtocol, DataConvertible {
    let header: Header
    let payload: Data

    /// Initializes a new `Message` by parsing a `header` and `payload` from `data`.
    init(data: Data, isExtended: Bool) throws {
        self.header = try Header(data: data, isExtended: isExtended)

        var reader = DataReader(data: data)
        reader.skip(header.size)
        payload = reader.readRemainingData()
    }

    init(header: Header, payload: Data) {
        self.header = header
        self.payload = payload
    }

    func asData() -> Data {
        header.asData() + payload
    }

    var type: MessageType { header.messageType }
    var steamIdentifier: UInt64? { header.extendedContent?.steamIdentifier }
    var sessionIdentifier: SessionIdentifier? { header.extendedContent?.sessionIdentifier }
}

extension Message {
    struct Header {

        struct ExtendedContent {
            let headerCanary: UInt8
            let steamIdentifier: UInt64
            let sessionIdentifier: SessionIdentifier
        }

        let messageType: MessageType
        let targetJobIdentifier: UInt64
        let sourceJobIdentifier: UInt64
        let extendedContent: ExtendedContent?
        let size: Int

        private let rawContent: Data?

        init(data: Data, isExtended: Bool) throws {
            var reader = DataReader(data: data)

            let messageTypeValue: UInt32 = reader.read()
            guard let messageType = EMsg(rawValue: Int(messageTypeValue)) else {
                throw MessageDecodeError.invalidMessageType
            }

            self.messageType = messageType

            if isExtended {
                let headerSize: UInt8 = reader.read()

                // Header version
                reader.skip(MemoryLayout<UInt16>.size)

                targetJobIdentifier = reader.read()
                sourceJobIdentifier = reader.read()
                let headerCanary: UInt8 = reader.read()

                let steamIdentifier: UInt64 = reader.read()
                let sessionIdentifier: SessionIdentifier = reader.read()

                extendedContent = .init(
                    headerCanary: headerCanary,
                    steamIdentifier: steamIdentifier,
                    sessionIdentifier: sessionIdentifier)
                rawContent = nil

                size = Int(headerSize)
            } else {
                targetJobIdentifier = reader.read()
                sourceJobIdentifier = reader.read()
                extendedContent = nil
                rawContent = nil

                size = [
                    MemoryLayout<UInt32>.size,
                    MemoryLayout<UInt64>.size,
                    MemoryLayout<UInt64>.size
                ].reduce(0, +)
            }
        }

        init(
            messageType: MessageType,
            targetJobIdentifier: UInt64 = ~UInt64(0),
            sourceJobIdentifier: UInt64 = ~UInt64(0),
            content: Data? = nil)
        {
            self.messageType = messageType
            self.targetJobIdentifier = targetJobIdentifier
            self.sourceJobIdentifier = sourceJobIdentifier
            extendedContent = nil
            rawContent = content
            size = [
                MemoryLayout<UInt32>.size,
                MemoryLayout<UInt64>.size,
                MemoryLayout<UInt64>.size,
                content?.count ?? 0
            ].reduce(0, +)
        }

        func asData() -> Data {
            var bytes = [
                UInt32(messageType.rawValue).bytes.reversed(),
                targetJobIdentifier.bytes,
                targetJobIdentifier.bytes
            ]

            if let rawContent = rawContent {
                bytes.append(rawContent.bytes)
            }

            return Data(bytes.flatMap { $0 })
        }
    }
}

enum MessageDecodeError: Error {
    case invalidMessageType
}
