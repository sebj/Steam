
import XCTest
@testable import Steam

final class EncryptionDataTests: XCTestCase {
    
    func testHmac() {
        let hmac = Data(repeating: 0, count: 16)
        let data = hmac + Data(repeating: 1, count: 16)
        let encryptionKey = EncryptionData(data)
        XCTAssertEqual(hmac, encryptionKey.hmac)
    }
    
}
