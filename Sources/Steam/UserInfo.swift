//
//  UserInfo.swift
//
//  Copyright © 2021 Sebastian Jachec. All rights reserved.
//

public struct UserInfo: OptionSet {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let status        = Self(rawValue: 1 << 0)
    public static let playerName    = Self(rawValue: 1 << 1)
    public static let queryPort     = Self(rawValue: 1 << 2)
    public static let sourceID      = Self(rawValue: 1 << 3)
    public static let presence      = Self(rawValue: 1 << 4)

    public static let lastSeen      = Self(rawValue: 1 << 6)
    public static let userClanRank  = Self(rawValue: 1 << 7)
    public static let gameExtraInfo = Self(rawValue: 1 << 8)
    public static let gameDataBlob  = Self(rawValue: 1 << 9)
    public static let clanData      = Self(rawValue: 1 << 10)
    public static let facebook      = Self(rawValue: 1 << 11)
    public static let richPresence  = Self(rawValue: 1 << 12)
    public static let broadcast     = Self(rawValue: 1 << 13)
    public static let watching      = Self(rawValue: 1 << 14)
}
