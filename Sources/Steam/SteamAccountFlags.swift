//
//  SteamAccountFlags.swift
//
//  Copyright © 2021 Sebastian Jachec. All rights reserved.
//

public struct SteamAccountFlags: Hashable, Equatable, OptionSet {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let personaNameSet             = Self(rawValue: 1 << 0)
    public static let unbannable                 = Self(rawValue: 1 << 1)
    public static let passwordSet                = Self(rawValue: 1 << 2)
    public static let support                    = Self(rawValue: 1 << 3)
    public static let admin                      = Self(rawValue: 1 << 4)
    public static let supervisor                 = Self(rawValue: 1 << 6)
    public static let appEditor                  = Self(rawValue: 1 << 7)
    public static let hardwareIdentifierSet      = Self(rawValue: 1 << 8)
    public static let personalQASet              = Self(rawValue: 1 << 9)
    public static let VACBeta                    = Self(rawValue: 1 << 10)
    public static let debug                      = Self(rawValue: 1 << 11)
    public static let disabled                   = Self(rawValue: 1 << 12)
    public static let limitedUser                = Self(rawValue: 1 << 13)
    public static let limitedUserForce           = Self(rawValue: 1 << 14)
    public static let emailValidated             = Self(rawValue: 1 << 15)
    public static let marketingTreatment         = Self(rawValue: 1 << 16)
    public static let OGGInviteOptOut            = Self(rawValue: 1 << 17)
    public static let forcePasswordChange        = Self(rawValue: 1 << 18)
    public static let forceEmailVerification     = Self(rawValue: 1 << 19)
    public static let logonExtraSecurity         = Self(rawValue: 1 << 20)
    public static let logonExtraSecurityDisabled = Self(rawValue: 1 << 21)
    public static let steam2MigrationComplete    = Self(rawValue: 1 << 21)
    public static let needLogs                   = Self(rawValue: 1 << 21)
    public static let lockdown                   = Self(rawValue: 1 << 21)
    public static let masterAppEditor            = Self(rawValue: 1 << 21)
    public static let bannedFromWebAPI           = Self(rawValue: 1 << 21)
    public static let clansOnlyFromFriends       = Self(rawValue: 1 << 21)
    public static let globalModerator            = Self(rawValue: 1 << 21)
}
