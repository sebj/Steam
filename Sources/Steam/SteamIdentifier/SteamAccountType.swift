//
//  SteamAccountType.swift
//
//  Copyright © 2020-2021 Sebastian Jachec. All rights reserved.
//

public enum SteamAccountType: UInt32 {
    case invalid = 0
    /// A regular user account.
    case individual = 1
    /// A multiseat (e.g. cybercafe) account.
    case multiseat = 2
    /// A persistent (not anonymous) game server account.
    case gameServer = 3
    case anonymousGameServer = 4
    /// Awaiting account credentials verification with a Steam authentication server.
    case pending = 5
    /// A Valve internal content server account.
    case valveContentServer = 6
    case steamGroup = 7
    /// A Steam group chat or lobby.
    case chat = 8
    /// A fake Steam ID for a local PSN account on PS3 or Live account on 360, etc.
    case consoleUser = 9
    /// An anonymous user account, used to create an account or reset a password.
    case anonymousUser = 10
}
