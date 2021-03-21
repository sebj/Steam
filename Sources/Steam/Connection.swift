//
//  Connection.swift
//  
//  Copyright © 2020-2021 Sebastian Jachec. All rights reserved.
//

import Combine
import Foundation
import Network

/// A bidirectional TCP connection between a local endpoint and a remote endpoint.
protocol ConnectionProtocol {

    var status: AnyPublisher<ConnectionStatus, Never> { get }

    /// A publisher that emits received data.
    var data: AnyPublisher<Data, Error> { get }

    /// Initializes a new TCP connection to a host and port.
    init?(host: String, port: Int, queue: DispatchQueue)

    func connect()
    func disconnect()

    func send(_ data: Data) -> AnyPublisher<Void, ConnectionSendError>
}

enum ConnectionStatus {
    case ready
    case disconnected
}

final class NetworkConnection: ConnectionProtocol {

    let status: AnyPublisher<ConnectionStatus, Never>
    let data: AnyPublisher<Data, Error>

    private let statusSubject = PassthroughSubject<ConnectionStatus, Never>()
    private let dataSubject = PassthroughSubject<Data, Error>()

    private let queue: DispatchQueue
    private var connection: NWConnection?

    init?(host: String, port: Int, queue: DispatchQueue) {
        self.queue = queue
        self.status = statusSubject.share().eraseToAnyPublisher()
        self.data = dataSubject.share().eraseToAnyPublisher()

        let host = NWEndpoint.Host(host)
        guard let port = NWEndpoint.Port(rawValue: UInt16(port)) else {
            return nil
        }

        let connection = NWConnection(host: host, port: port, using: .tcp)
        self.connection = connection

        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.statusSubject.send(.ready)
                self?.receive()
            case .cancelled, .failed:
                self?.statusSubject.send(.disconnected)
            default:
                return
            }
        }
    }

    func connect() {
        connection?.start(queue: queue)
    }

    func disconnect() {
        connection?.cancel()
    }

    private func receive() {
        let maximumLength = Int(powf(2, 16))

        connection?.receive(
            minimumIncompleteLength: 1,
            maximumLength: maximumLength)
        { [weak self] (data, _, isComplete, error) in
            if let data = data {
                self?.dataSubject.send(data)
            }

            if isComplete {
                self?.connection?.cancel()
                return
            }

            if error != nil {
                self?.connection?.cancel()
                return
            }

            self?.receive()
        }
    }

    func send(_ data: Data) -> AnyPublisher<Void, ConnectionSendError> {
        Deferred {
            Future { [weak self] promise in
                guard let connection = self?.connection else {
                    promise(.failure(ConnectionSendError.unknown))
                    return
                }

                connection.send(content: data, completion: .contentProcessed { error in
                    if let error = error {
                        promise(.failure(ConnectionSendError.network(error)))
                        return
                    }

                    promise(.success(()))
                })
            }
        }
        .eraseToAnyPublisher()
    }
}

enum ConnectionSendError: Error {
    case network(Error)
    case unknown
}
