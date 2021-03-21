//
//  Packet.swift
//  
//  Copyright © 2021 Sebastian Jachec. All rights reserved.
//

import Foundation

struct Packet {

    enum ReadError: Error {
        case invalidValidationMagic
    }

    let content: Data
    private let validationMagic = "VT01"

    /// Initialize a new packet by reading and parsing raw data from a `DataReader`.
    init(_ reader: inout DataReader) throws {
        var contentLengthBytes: UInt32 = reader.read()
        if contentLengthBytes > reader.remainingDataSize {
            contentLengthBytes = UInt32(reader.remainingDataSize)
        }

        let validationMagic = String(data: reader.read(MemoryLayout<UInt32>.size), encoding: .utf8)
        guard validationMagic == self.validationMagic else {
            throw ReadError.invalidValidationMagic
        }

        content = reader.readRemainingData()
    }

    init(content: Data) {
        self.content = content
    }

    func asData() -> Data {
        Data(
            [
                UInt32(content.count).bytes.reversed(),
                Data(validationMagic.utf8).bytes,
                content.bytes
            ]
            .flatMap { $0 }
        )
    }
}
