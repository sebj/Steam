//
//  ChatMode.swift
//
//  Copyright © 2020-2021 Sebastian Jachec. All rights reserved.
//

enum ChatMode: UInt32 {
    case old = 0
    case new = 2

    static let `default` = ChatMode.new
}
