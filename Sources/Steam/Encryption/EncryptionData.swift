//
//  EncryptionData.swift
//  
//  Copyright © 2021 Sebastian Jachec. All rights reserved.
//

import Foundation

struct EncryptionData {
    let plainData: Data

    init(_ data: Data) {
        self.plainData = data
    }

    var hmac: Data {
        plainData.prefix(16)
    }
}
