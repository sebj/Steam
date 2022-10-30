//
//  SteamService+Friends.swift
//
//  Copyright © 2021 Sebastian Jachec. All rights reserved.
//

import Combine
import Foundation

public enum SteamFriendRequest {
    case accountName(String)
    case email(String)
    case identifier(SteamIdentifier)
}

extension SteamService {

    /// Send a friend request or accept an incoming friend request.
    public func addFriend(_ request: SteamFriendRequest) -> AnyPublisher<Void, SendError> {
        guard case .encrypted = encryption else {
            return Fail(error: SendError.unencryptedConnection).eraseToAnyPublisher()
        }

        var addFriendRequest = CMsgClientAddFriend()

        switch request {
        case let .accountName(accountName):
            addFriendRequest.accountnameOrEmailToAdd = accountName
        case let .email(email):
            addFriendRequest.accountnameOrEmailToAdd = email
        case let .identifier(identifier):
            addFriendRequest.steamidToAdd = identifier.rawValue
        }

        let payload: Data
        do {
            payload = try addFriendRequest.serializedData()
        } catch {
            return Fail(error: SendError.failedToEncode(error)).eraseToAnyPublisher()
        }

        let message = ProtobufMessage(
            header: .init(messageType: .kEmsgClientRemoveFriend),
            payload: payload
        )

        return send(message)
    }

    public func removeFriend(_ identifier: SteamIdentifier) -> AnyPublisher<Void, SendError> {
        guard case .encrypted = encryption else {
            return Fail(error: SendError.unencryptedConnection).eraseToAnyPublisher()
        }

        var request = CMsgClientRemoveFriend()
        request.friendid = identifier.rawValue

        let payload: Data
        do {
            payload = try request.serializedData()
        } catch {
            return Fail(error: SendError.failedToEncode(error)).eraseToAnyPublisher()
        }

        let message = ProtobufMessage(
            header: .init(messageType: .kEmsgClientRemoveFriend),
            payload: payload
        )

        return send(message)
    }
}
