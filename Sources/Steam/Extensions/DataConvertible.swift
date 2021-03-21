//
//  DataConvertible.swift
//
//  Copyright © 2021 Sebastian Jachec. All rights reserved.
//

import Foundation

protocol DataConvertible {
    func asData() throws -> Data
}
