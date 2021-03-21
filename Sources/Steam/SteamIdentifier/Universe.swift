//
//  Universe.swift
//
//  Copyright © 2021 Sebastian Jachec. All rights reserved.
//

/// Steam universes. Each universe is a self-contained Steam instance.
/// Seealso: https://partner.steamgames.com/doc/api/steam_api#EUniverse
public enum Universe: UInt32 {
    case invalid
    /// The standard public universe.
    case `public`
    /// The beta universe used inside Valve.
    case beta
    /// The internal universe used inside Valve.
    case `internal`
    /// The dev universe used inside Valve.
    case dev
}
