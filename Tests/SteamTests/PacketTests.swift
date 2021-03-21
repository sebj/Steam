//
//  PacketTests.swift
//  
//  Copyright © 2021 Sebastian Jachec. All rights reserved.
//

import XCTest
@testable import Steam

final class PacketTests: XCTestCase {
    
    func testContent() throws {
        let content = Data(repeating: 0, count: 8)
        let packet = Packet(content: content)
        let packetData = packet.asData()
        
        var reader = DataReader(data: packetData)
        let rawPacket = try Packet(&reader)
        
        XCTAssertEqual(rawPacket.content, content)
    }
    
    func testInitializerDoesNotThrow_whenDataHasValidMagic() throws {
        let data = makeData()
        var reader = DataReader(data: data)
        XCTAssertNoThrow(try Packet(&reader))
    }
    
    func testInitializerThrows_whenDataHasInvalidMagic() throws {
        let data = makeData(magic: "INVALID")
        
        var reader = DataReader(data: data)
        XCTAssertThrowsError(try Packet(&reader)) { error in
            XCTAssertEqual(error as? Packet.ReadError, Packet.ReadError.invalidValidationMagic)
        }
    }
    
    private func makeData(
        content: Data = .init(repeating: 0, count: 8),
        magic: String = "VT01") -> Data
    {
        Data(
            [
                UInt32(content.count).bytes.reversed(),
                Data(magic.utf8).bytes,
                content.bytes
            ]
            .flatMap { $0 }
        )
    }
}
