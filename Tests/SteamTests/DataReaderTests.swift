@testable import Steam
import XCTest

final class DataReaderTests: XCTestCase {
    
    func testHasDataIsTrue_whenInitializedWithPopulatedData() {
        let data = Data(repeating: 0, count: 8)
        let reader = DataReader(data: data)
        XCTAssertTrue(reader.hasData)
    }
    
    func testHasDataIsFalse_whenAllDataHasBeenRead() {
        let data = Data(repeating: 0, count: 8)
        
        var reader = DataReader(data: data)
        _ = reader.read(data.count)
        
        XCTAssertFalse(reader.hasData)
    }
    
    func testRemainingDataSizeIsDataSize_whenInitializedWithData() {
        let data = Data(repeating: 0, count: 8)
        let reader = DataReader(data: data)
        XCTAssertEqual(reader.remainingDataSize, data.count)
    }
    
    func testRemainingDataSizeIs0_whenAllDataHasBeenRead() {
        let data = Data(repeating: 0, count: 8)
        var reader = DataReader(data: data)
        _ = reader.read(data.count)
        
        XCTAssertEqual(reader.remainingDataSize, 0)
    }
    
    func testAllDataIsReturned_whenReadingRemainingData_givenNoDataHasBeenRead() {
        let data = Data(repeating: 0, count: 8)
        
        var reader = DataReader(data: data)
        let remainingData = reader.readRemainingData()
        
        XCTAssertEqual(remainingData, data)
    }
    
    func testUnreadDataIsReturned_whenReadingRemainingData_whenDataHasPreviouslyBeenRead() {
        let data = Data(repeating: 0, count: 8)
        
        var reader = DataReader(data: data)
        _ = reader.read(4)
        
        let remainingData = reader.readRemainingData()
        
        XCTAssertEqual(remainingData, data[4..<data.endIndex])
    }
    
    func testCanReadIsTrue_whenUnreadDataIsMoreThanGivenSize() {
        let data = Data(repeating: 0, count: 8)
        let reader = DataReader(data: data)
        XCTAssertTrue(reader.canRead(7))
    }
    
    func testCanReadIsTrue_whenUnreadDataIsEqualToGivenSize() {
        let data = Data(repeating: 0, count: 8)
        let reader = DataReader(data: data)
        XCTAssertTrue(reader.canRead(8))
    }
    
    func testCanReadIsFalse_whenUnreadDataIsLessThanGivenSize() {
        let data = Data(repeating: 0, count: 8)
        
        var reader = DataReader(data: data)
        _ = reader.read(8)
        
        XCTAssertFalse(reader.canRead(1))
    }
}
