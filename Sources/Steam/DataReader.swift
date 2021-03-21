//
//  DataReader.swift
//
//  Copyright © 2021 Sebastian Jachec. All rights reserved.
//

import Foundation

struct DataReader {

    private let data: Data
    private var index: Data.Index
    private var range: Range<Data.Index>

    init(data: Data) {
        self.data = data
        index = data.startIndex
        range = data.startIndex..<data.endIndex
    }

    var hasData: Bool {
        remainingDataSize > 0
    }

    var remainingDataSize: Int {
        guard index < data.endIndex else {
            return 0
        }

        return data.endIndex - index
    }

    func canRead(_ size: Int) -> Bool {
        remainingDataSize >= size
    }

    mutating func skip(_ size: Int) {
        guard hasData else {
            return
        }

        index = index.advanced(by: size)
    }

    mutating func read(_ size: Int) -> Data {
        guard hasData else {
            return Data()
        }

        let upperBound = index.advanced(by: size)

        range = index..<upperBound
        let data = self.data[range]

        index = upperBound

        return data
    }

    mutating func read<Type>() -> Type where Type: FixedWidthInteger {
        guard hasData else {
            return Type(littleEndianBytes: [])
        }

        return Type(littleEndianBytes: read(MemoryLayout<Type>.size))
    }

    mutating func readRemainingData() -> Data {
        guard hasData else {
            return Data()
        }

        range = index..<data.endIndex
        index = data.endIndex
        return data[range]
    }
}
