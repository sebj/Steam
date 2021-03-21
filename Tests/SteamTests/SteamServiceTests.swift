
import Combine
import XCTest
@testable import Steam

final class SteamServiceTests: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()
    private let server = SteamServer(host: "HOST", port: Int.random(in: 0...10))
    
    func testConnectionCreated_whenConnectIsCalled_givenConnectionDoesNotExist() {
        let expectation = self.expectation(description: #function)

        let connectionFactory: ConnectionFactory = { host, port, _ in
            expectation.fulfill()
            XCTAssertEqual(host, self.server.host)
            XCTAssertEqual(port, self.server.port)
            return StubConnection()
        }
        
        let service = SteamService(connectionFactory: connectionFactory)
        _ = service.connect(to: server).sink()
        
        waitForExpectations(timeout: 0)
    }
    
    func testConnectionNotCreated_whenConnectIsCalled_givenConnectionExists() {
        let expectation = self.expectation(description: #function)

        let connectionFactory: ConnectionFactory = { host, port, _ in
            expectation.fulfill()
            return StubConnection()
        }
        
        let service = SteamService(connectionFactory: connectionFactory)
        _ = service.connect(to: server).sink()
        _ = service.connect(to: server).sink()
        
        waitForExpectations(timeout: 0)
    }
    
    func testSendThrowsDisconnectedError_whenDisconnected() {
        let expectation = self.expectation(description: #function)
        let connectionFactory: ConnectionFactory = { host, port, _ in StubConnection() }
        let service = SteamService(connectionFactory: connectionFactory)
        
        let message = ProtobufMessage(header: .init(messageType: .kEmsgClientLogon), payload: Data())
        
        service.send(message)
            .sink { completion in
                expectation.fulfill()
                
                guard case .failure(SteamService.SendError.disconnected) = completion else {
                    XCTFail("Completed with \(completion), expected .failure(SendError.disconnected)")
                    return
                }
            } receiveValue: {
                expectation.fulfill()
                XCTFail("Expected completion with .failure(SendError.disconnected)")
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0)
    }
    
    func testSendThrowsFailedToEncode_whenGivenDataFailsToEncode() {
        let expectation = self.expectation(description: #function)
        let connectionFactory: ConnectionFactory = { host, port, _ in StubConnection() }
        let service = SteamService(connectionFactory: connectionFactory)
        
        enum TestError: Swift.Error {
            case failedToEncode
        }
        
        struct DataBla: DataConvertible {
            func asData() throws -> Data {
                throw TestError.failedToEncode
            }
        }
        
        _ = service.connect(to: SteamServer(host: "", port: 0)).sink()
        
        service.send(DataBla())
            .sink { completion in
                expectation.fulfill()
                
                guard case .failure(SteamService.SendError.failedToEncode(TestError.failedToEncode)) = completion else {
                    XCTFail("Completed with \(completion), expected .failure(SteamService.SendError.failedToEncode(TestError.failedToEncode))")
                    return
                }
            } receiveValue: {
                expectation.fulfill()
                XCTFail("Received value but expected completion with .failure(SteamService.SendError.failedToEncode(TestError.failedToEncode))")
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0)
    }
    
    func testLoginThrowsDisconnected_whenDisconnected() {
        let expectation = self.expectation(description: #function)
        let service = SteamService(connectionFactory: makeConnectionFactory())
        
        service.login(username: "", credentials: .loginKey(""), steamGuard: .none)
            .sink { completion in
                expectation.fulfill()
                
                guard case .failure(SteamService.LoginError.disconnected) = completion else {
                    XCTFail("Completed with \(completion), expected .failure(SteamService.LoginError.disconnected)")
                    return
                }
            } receiveValue: { _ in
                expectation.fulfill()
                XCTFail("Received value but expected completion with .failure(SteamService.LoginError.disconnected)")
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0)
    }
}

// MARK: - Send Data

extension SteamServiceTests {
    
    func testLoginSendsData_whenValidUsernameIsProvided() throws {
        let expectation = self.expectation(description: #function)
        let connection = try XCTUnwrap(StubConnection())
        let connectionFactory = makeConnectionFactory(connection)
        let service = SteamService(connectionFactory: connectionFactory)
        _ = service.connect(to: SteamServer(host: "", port: 0))
        
        service.login(username: "test", credentials: .loginKey("bla"), steamGuard: .none)
            .sink(receiveCompletion: { _ in expectation.fulfill() }, receiveValue: { _ in expectation.fulfill() })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 0)
        XCTAssertEqual(connection.sentData.count, 1)
        XCTAssertFalse(connection.sentData[0].isEmpty)
    }
    
    func testSetUIModeThrows_whenConnectionIsUnencrypted() throws {
        let expectation = self.expectation(description: #function)
        let service = SteamService(connectionFactory: makeConnectionFactory())
        
        service.setUIMode(.mobile)
            .sink { completion in
                expectation.fulfill()
                
                guard case .failure(SteamService.SendError.unencryptedConnection) = completion else {
                    XCTFail("Completed with \(completion), expected .failure(SteamService.SendError.unencryptedConnection)")
                    return
                }
            } receiveValue: { _ in
                expectation.fulfill()
                XCTFail("Received value but expected completion with .failure(SteamService.SendError.unencryptedConnection)")
            }
            .store(in: &cancellables)

        
        waitForExpectations(timeout: 0)
    }
    
    func testSetFetchUserInfoThrows_whenConnectionIsUnencrypted() throws {
        let expectation = self.expectation(description: #function)
        let service = SteamService(connectionFactory: makeConnectionFactory())
        
        service.fetchUserInfo(userIdentifiers: [SteamIdentifier()])
            .sink { completion in
                expectation.fulfill()
                
                guard case .failure(SteamService.SendError.unencryptedConnection) = completion else {
                    XCTFail("Completed with \(completion), expected .failure(SteamService.SendError.unencryptedConnection)")
                    return
                }
            } receiveValue: { _ in
                expectation.fulfill()
                XCTFail("Received value but expected completion with .failure(SteamService.SendError.unencryptedConnection)")
            }
            .store(in: &cancellables)

        
        waitForExpectations(timeout: 0)
    }
    
    func testAddFriendThrows_whenConnectionIsUnencrypted() throws {
        let expectation = self.expectation(description: #function)
        let service = SteamService(connectionFactory: makeConnectionFactory())
        
        service.addFriend(.accountName("test"))
            .sink { completion in
                expectation.fulfill()
                
                guard case .failure(SteamService.SendError.unencryptedConnection) = completion else {
                    XCTFail("Completed with \(completion), expected .failure(SteamService.SendError.unencryptedConnection)")
                    return
                }
            } receiveValue: { _ in
                expectation.fulfill()
                XCTFail("Received value but expected completion with .failure(SteamService.SendError.unencryptedConnection)")
            }
            .store(in: &cancellables)

        
        waitForExpectations(timeout: 0)
    }
    
    func testRemoveFriendThrows_whenConnectionIsUnencrypted() throws {
        let expectation = self.expectation(description: #function)
        let service = SteamService(connectionFactory: makeConnectionFactory())
        
        service.removeFriend(SteamIdentifier())
            .sink { completion in
                expectation.fulfill()
                
                guard case .failure(SteamService.SendError.unencryptedConnection) = completion else {
                    XCTFail("Completed with \(completion), expected .failure(SteamService.SendError.unencryptedConnection)")
                    return
                }
            } receiveValue: { _ in
                expectation.fulfill()
                XCTFail("Received value but expected completion with .failure(SteamService.SendError.unencryptedConnection)")
            }
            .store(in: &cancellables)

        
        waitForExpectations(timeout: 0)
    }
}

private extension SteamServiceTests {
    func makeConnectionFactory(_ connection: ConnectionProtocol = StubConnection()!) -> ConnectionFactory {
        { host, port, _ in connection }
    }
}

private final class StubConnection: ConnectionProtocol {
    
    let status: AnyPublisher<ConnectionStatus, Never>
    let data: AnyPublisher<Data, Error>
    
    var sentData = [Data]()
    
    let dataSubject = PassthroughSubject<Data, Error>()
    
    convenience init?() {
        self.init(host: "", port: -1, queue: .main)
    }
    
    init?(host: String, port: Int, queue: DispatchQueue) {
        status = Empty(completeImmediately: true).eraseToAnyPublisher()
        data = dataSubject.eraseToAnyPublisher()
    }
    
    func connect() {}
    
    func disconnect() {}
    
    func send(_ data: Data) -> AnyPublisher<Void, ConnectionSendError> {
        sentData.append(data)
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }
}
