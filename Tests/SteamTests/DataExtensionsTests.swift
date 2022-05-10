import XCTest
@testable import Steam

final class DataExtensionsTests: XCTestCase {
    
    func testInitWithLittleEndianBytes() {
        let value = UInt32(littleEndianBytes: [1, 0, 0, 0])
        XCTAssertEqual(value, 1)
    }
}
