//
//  MessageProtocol.swift
//
//  Copyright © 2020-2021 Sebastian Jachec. All rights reserved.
//

import Foundation

protocol MessageProtocol {
    var type: MessageType { get }
    var steamIdentifier: UInt64? { get }
    var sessionIdentifier: SessionIdentifier? { get }
    var payload: Data { get }
}
