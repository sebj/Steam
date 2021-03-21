//
//  MessageType.swift
//
//  Copyright © 2020-2021 Sebastian Jachec. All rights reserved.
//

typealias MessageType = EMsg

extension MessageType {
    var isProtobuf: Bool {
        UInt32(rawValue).isProtobuf
    }
}
