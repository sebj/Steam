//
//  SteamIdentifier.swift
//
//  Copyright © 2020-2021 Sebastian Jachec. All rights reserved.
//

/// A unique 64-bit identifier for a Steam user account.
/// See https://developer.valvesoftware.com/wiki/SteamID
public struct SteamIdentifier: Hashable, Equatable {
    public var accountIdentifier: UInt32
    public var instance: UInt32
    public var universe: SteamUniverse
    public var accountType: SteamAccountType

    public init(
        accountIdentifier: UInt32 = 0,
        instance: UInt32 = 1,
        universe: SteamUniverse = .public,
        accountType: SteamAccountType = .individual)
    {
        self.accountIdentifier = accountIdentifier
        self.instance = instance
        self.universe = universe
        self.accountType = accountType
    }

    public init?(_ rawValue: UInt64) {
        accountIdentifier = UInt32(rawValue & 0xFFFFFFFF)
        instance = UInt32((rawValue >> 32) & 0xFFFFF)

        guard let universe = SteamUniverse(rawValue: UInt32((rawValue >> 56) & 0xFF)) else {
            return nil
        }

        self.universe = universe

        guard let accountType = SteamAccountType(rawValue: UInt32((rawValue >> 52) & 0xF)) else {
            return nil
        }

        self.accountType = accountType
    }

    public var rawValue: UInt64 {
        (UInt64(universe.rawValue) << 56)
            | (UInt64(accountType.rawValue) << 52)
            | (UInt64(instance) << 32)
            | UInt64(accountIdentifier)
    }
}
