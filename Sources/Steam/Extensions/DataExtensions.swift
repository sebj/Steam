// https://forums.swift.org/t/convert-uint8-to-int/30117/12
extension FixedWidthInteger {
    init<ByteCollection>(
        littleEndianBytes bytes: ByteCollection
    ) where ByteCollection: Collection, ByteCollection.Element == UInt8 {
        var iterator = bytes.makeIterator()
        self.init(littleEndianBytes: &iterator)
    }
    
    init<Iterator>(
        littleEndianBytes iterator: inout Iterator
    ) where Iterator: IteratorProtocol, Iterator.Element == UInt8 {
        self = stride(from: 0, to: Self.bitWidth, by: 8).reduce(into: 0) {
            guard let nextElement = iterator.next() else {
                return
            }

            $0 |= Self(truncatingIfNeeded: nextElement) &<< $1
        }
    }
}

extension UnsignedInteger {
    var bytes: [UInt8] {
        let start = (MemoryLayout<Self>.size - 1) * 8
        return stride(from: start, through: 0, by: -8).map {
            UInt8(truncatingIfNeeded: UInt64(self) >> UInt64($0))
        }
    }
}
