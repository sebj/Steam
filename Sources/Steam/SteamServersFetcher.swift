//
//  SteamServersFetcher.swift
//
//  Copyright © 2021 Sebastian Jachec. All rights reserved.
//

import Combine
import Foundation

public final class SteamServersFetcher {

    public enum Error: Swift.Error {
        case failedToCreateURL
        case other(Swift.Error)
    }

    private let decoder = JSONDecoder()

    public init() {}

    /// Fetch the latest listing of available servers from the Steam Web API.
    public func fetchServers(urlSession: URLSession = .shared) -> AnyPublisher<[SteamServer], Error> {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.steampowered.com"
        urlComponents.percentEncodedPath = "/ISteamDirectory/GetCMList/v1"
        urlComponents.percentEncodedQueryItems = [.init(name: "cellid", value: "0")]

        guard let url = urlComponents.url else {
            return Fail(error: .failedToCreateURL).eraseToAnyPublisher()
        }

        return urlSession.dataTaskPublisher(for: url)
            .map { data, _ in data }
            .decode(type: ServerListResponse.self, decoder: decoder)
            .map(\.response.serverHosts)
            .map { servers in
                servers.compactMap {
                    let components = $0.split(separator: ":")
                    guard components.count == 2 else {
                        return nil
                    }

                    let host = String(components[0])
                    guard let port = Int(components[1]) else {
                        return nil
                    }

                    return SteamServer(host: host, port: port)
                }
            }
            .mapError(Error.other)
            .eraseToAnyPublisher()
    }
}

private struct ServerListResponse: Decodable {
    let response: Response

    struct Response: Decodable {
        let serverHosts: [String]

        enum CodingKeys: String, CodingKey {
            case serverHosts = "serverlist"
        }
    }
}
