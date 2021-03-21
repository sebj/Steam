//
//  ProtobufMessage.swift
//
//  Copyright © 2020-2021 Sebastian Jachec. All rights reserved.
//

import Foundation

struct ProtobufMessage: MessageProtocol, DataConvertible {

    var header: Header
    let payload: Data

    /// Initializes a new `ProtobufMessage` by parsing a `header` and `payload` from `data`.
    init(data: Data) throws {
        self.header = try Header(data: data)
        let headerSize = MemoryLayout<UInt32>.size * 2
        self.payload = data[data.startIndex.advanced(by: headerSize)..<data.endIndex]
    }

    init(header: Header, payload: Data) {
        self.header = header
        self.payload = payload
    }

    func asData() throws -> Data {
        let bytes = [
            try header.asData().bytes,
            payload.bytes
        ].flatMap { $0 }

        return Data(bytes)
    }

    var type: MessageType { header.messageType }
    var steamIdentifier: UInt64? {
        let identifier = header.content.steamid
        if header.content.hasSteamid && identifier != 0 {
            return identifier
        }

        return nil
    }

    var sessionIdentifier: SessionIdentifier? {
        let identifier = header.content.clientSessionid
        if header.content.hasClientSessionid && identifier != 0 {
            return identifier
        }

        return nil
    }
}

extension ProtobufMessage {
    struct Header {

        typealias Content = CMsgProtoBufHeader

        let messageType: MessageType
        var content: Content

        static let fullSize = MemoryLayout<UInt32>.size * 2

        init(data: Data) throws {
            var reader = DataReader(data: data)

            let rawMessageType = UInt32(littleEndianBytes: reader.read(MemoryLayout<UInt32>.size)).withoutProtobufBit
            guard let messageType = EMsg(rawValue: Int(rawMessageType)) else {
                throw Error.invalidMessageType
            }

            self.messageType = messageType

            // Content size
            reader.skip(MemoryLayout<UInt32>.size)

            content = try Content(serializedData: reader.readRemainingData())
        }

        init(messageType: MessageType, content: Content = .init()) {
            self.messageType = messageType
            self.content = content
        }

        func asData() throws -> Data {
            let messageTypeWithProtobuf = UInt32(messageType.rawValue).rawValueWithProtobufBit
            let contentData = try content.serializedData().bytes
            let contentSize = UInt32(contentData.count)

            let bytes = [
                messageTypeWithProtobuf.bytes.reversed(),
                contentSize.bytes.reversed(),
                contentData
            ].flatMap { $0 }

            return Data(bytes)
        }

        enum Error: Swift.Error {
            case invalidMessageType
        }
    }
}
