//
//  EncryptionRequest.swift
//
//  Copyright © 2020-2021 Sebastian Jachec. All rights reserved.
//

import Foundation

struct EncryptionRequest {
    let protocolVersion: UInt32
    let universe: Universe
    let challenge: Data

    init(data: Data) throws {
        var reader = DataReader(data: data)
        protocolVersion = reader.read()

        let universeValue: UInt32 = reader.read()
        guard let universe = Universe(rawValue: universeValue) else {
            throw Error.invalidUniverse
        }

        self.universe = universe

        challenge = reader.readRemainingData()
    }

    enum Error: Swift.Error {
        case invalidUniverse
    }
}
