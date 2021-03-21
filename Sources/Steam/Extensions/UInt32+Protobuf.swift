//
//  UInt32+Protobuf.swift
//
//  Copyright © 2020-2021 Sebastian Jachec. All rights reserved.
//

extension UInt32 {
    private static let protobufBitMask: Self = 0x80000000

    var isProtobuf: Bool {
        (self & Self.protobufBitMask) > 0
    }

    var withoutProtobufBit: Self {
        self & ~Self.protobufBitMask
    }

    var rawValueWithProtobufBit: Self {
        self | Self.protobufBitMask
    }
}
