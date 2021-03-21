//
//  EncryptionResult.swift
//
//  Copyright © 2020-2021 Sebastian Jachec. All rights reserved.
//

import Foundation

struct EncryptionResult {

    let result: SteamResult

    init(data: Data) {
        let resultValue = UInt32(littleEndianBytes: data.bytes)
        result = SteamResult(rawValue: resultValue) ?? .invalid
    }
}
