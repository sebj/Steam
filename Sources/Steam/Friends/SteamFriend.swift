//
//  SteamFriend.swift
//
//  Copyright © 2021 Sebastian Jachec. All rights reserved.
//

public struct SteamFriend: Hashable, Equatable {
    public let identifier: SteamIdentifier
    public let relationship: Relationship
}

public extension SteamFriend {
    enum Relationship: UInt32 {
        case none
        case blocked
        case requestRecipient
        case friend
        case requestInitiator
        case ignored
        case ignoredFriend
        @available(*, deprecated)
        case suggestedFriend
    }
}
