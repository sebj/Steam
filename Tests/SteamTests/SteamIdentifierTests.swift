
import XCTest
@testable import Steam

final class SteamIdentifierTests: XCTestCase {
    
    private let rawValue: UInt64 = 76561198040793451
    
    func testInitWithRawValue() throws {
        let identifier = try XCTUnwrap(SteamIdentifier(rawValue))
        
        XCTAssertEqual(identifier.accountIdentifier, 80527723)
        XCTAssertEqual(identifier.instance, 1)
        XCTAssertEqual(identifier.universe, .public)
        XCTAssertEqual(identifier.accountType, .individual)
    }
    
    func testRawValue() {
        let identifier = SteamIdentifier(
            accountIdentifier: 80527723,
            instance: 1,
            universe: .public,
            accountType: .individual)
        
        XCTAssertEqual(identifier.rawValue, rawValue)
    }
    
}
