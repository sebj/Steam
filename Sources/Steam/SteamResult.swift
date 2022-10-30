//
//  SteamResult.swift
//
//  Copyright © 2020-2021 Sebastian Jachec. All rights reserved.
//

/// Result code, frequently returned by functions, callbacks, and call results from both the Steamworks API.
/// Seealso: https://partner.steamgames.com/doc/api/steam_api#EResult
public enum SteamResult: UInt32 {
    case invalid = 0
    case success = 1
    /// Generic failure.
    case failure = 2
    /// Your Steam client doesn't have a connection to the back-end.
    case noConnection = 3
    /// Password/ticket is invalid.
    case invalidPassword = 5
    /// The user is logged in elsewhere.
    case loggedInElsewhere = 6
    /// Protocol version is incorrect.
    case invalidProtocolVersion = 7
    /// A parameter is incorrect.
    case invalidParameter = 8
    /// File was not found.
    case fileNotFound = 9
    /// Called method is busy - action not taken.
    case busy = 10
    /// Called object was in an invalid state.
    case invalidState = 11
    /// The name was invalid.
    case invalidName = 12
    /// The email was invalid.
    case invalidEmail = 13
    /// The name is not unique.
    case duplicateName = 14
    /// Access is denied.
    case accessDenied = 15
    /// Operation timed out.
    case timeout = 16
    /// The user is VAC2 banned.
    case userBanned = 17
    /// Account not found.
    case accountNotFound = 18
    /// The Steam ID was invalid.
    case invalidSteamID = 19
    /// The requested service is currently unavailable.
    case serviceUnavailable = 20
    /// The user is not logged on.
    case notLoggedOn = 21
    /// Request is pending, it may be in process or waiting on third party.
    case pending = 22
    case encryptionOrDecryptionFailure = 23
    case insufficientPrivileges = 24
    case limitExceeded = 25
    /// Access has been revoked (used for revoked guest passes.)
    case accessRevoked = 26
    /// License/Guest pass the user is trying to access is expired.
    case expired = 27
    /// Guest pass has already been redeemed by account, cannot be used again.
    case alreadyRedeemed = 28
    /// The request is a duplicate and the action has already occurred in the past, ignored this time.
    case duplicateRequest = 29
    /// All the games in this guest pass redemption request are already owned by the user.
    case alreadyOwned = 30
    case ipAddressNotFound = 31
    /// Failed to write change to the data store.
    case persistFailed = 32
    /// Failed to acquire access lock for this operation.
    case lockingFailed = 33
    /// The logon session has been replaced.
    case logonSessionReplaced = 34
    /// Failed to connect.
    case connectFailed = 35
    /// The authentication handshake has failed.
    case handshakeFailed = 36
    /// There has been a generic IO failure.
    case ioFailure = 37
    /// The remote server has disconnected.
    case remoteDisconnect = 38
    /// Failed to find the shopping cart requested.
    case shoppingCartNotFound = 39
    /// A user blocked the action.
    case blocked = 40
    /// The target is ignoring sender.
    case ignored = 41
    /// Nothing matching the request found.
    case noMatch = 42
    /// The account is disabled.
    case accountDisabled = 43
    /// This service is not accepting content changes right now.
    case serviceReadOnly = 44
    /// Account doesn't have value, so this feature isn't available.
    case accountNotFeatured = 45
    /// Allowed to take this action, but only because requester is admin.
    case administratorOK = 46
    /// A Version mismatch in content transmitted within the Steam protocol.
    case contentVersion = 47
    /// The current community manager (server) can't service the user making a request, user should try another.
    case tryAnotherServer = 48
    /// You are already logged in elsewhere, this cached credential login has failed.
    case passwordRequiredToKickSession = 49
    /// The user is logged in elsewhere. (Use case LoggedInElsewhere = instead!)
    case alreadyLoggedInElsewhere = 50
    /// Long running operation has suspended/paused. (eg. content download.)
    case suspended = 51
    /// Operation has been canceled, typically by user. (eg. a content download.)
    case cancelled = 52
    /// Operation canceled because data is ill formed or unrecoverable.
    case dataCorruption = 53
    /// Operation canceled - not enough disk space.
    case diskFull = 54
    /// The remote or IPC call has failed.
    case remoteCallFailed = 55
    /// Password could not be verified as it's unset server side.
    case passwordUnset = 56
    /// External account (PSN, Facebook...) is not linked to a Steam account.
    case externalAccountUnlinked = 57
    /// PSN ticket was invalid.
    case psnTicketInvalid = 58
    /// External account (PSN, Facebook...) is already linked to some other account, must explicitly request
    /// to replace/delete the link first.
    case externalAccountAlreadyLinked = 59
    /// The sync cannot resume due to a conflict between the local and remote files.
    case remoteFileConflict = 60
    /// The requested new password is not allowed.
    case illegalPassword = 61
    /// New value is the same as the old one. This is used for secret question and answer.
    case sameAsPreviousValue = 62
    /// Account login denied due to 2nd factor authentication failure.
    case accountLogonDenied = 63
    /// The requested new password is not legal.
    case cannotUseOldPassword = 64
    /// Account login denied due to auth code invalid.
    case invalidLoginAuthCode = 65
    /// Account login denied due to 2nd factor auth failure - and no mail has been sent.
    case accountLogonDeniedNoMail = 66
    /// The users hardware does not support Intel's Identity Protection Technology (IPT).
    case hardwareNotCapableOfIPT = 67
    /// Intel's Identity Protection Technology (IPT) has failed to initialize.
    case iptInitError = 68
    /// Operation failed due to parental control restrictions for current user.
    case parentalControlRestricted = 69
    /// Facebook query returned an error.
    case facebookQueryError = 70
    /// Account login denied due to an expired auth code.
    case expiredLoginAuthCode = 71
    /// The login failed due to an IP restriction.
    case ipLoginRestrictionFailed = 72
    /// The current users account is currently locked for use. This is likely due to a hijacking
    /// and pending ownership verification.
    case accountLocked = 73
    case accountLogonDeniedEmailVerificationRequired = 74
    case noMatchingURL = 75
    /// Bad Response due to a Parse failure, missing field, etc.
    case badResponse = 76
    /// The user cannot complete the action until they re-enter their password.
    case requirePasswordReEntry = 77
    /// The value entered is outside the acceptable range.
    case valueOutOfRange = 78
    /// Something happened that we didn't expect to ever happen.
    case unexpectedError = 79
    /// The requested service has been configured to be unavailable.
    case disabled = 80
    /// The files submitted to the custom executable generation (CEG) server are not valid.
    case invalidCEGSubmission = 81
    /// The device being used is not allowed to perform this action.
    case restrictedDevice = 82
    /// The action could not be complete because it is region restricted.
    case regionLocked = 83
    /// Temporary rate limit exceeded, try again later, different from case LimitExceeded = which may be permanent.
    case rateLimitExceeded = 84
    /// Need two-factor code to login.
    case accountLoginDeniedNeedTwoFactor = 85
    /// The thing we're trying to access has been deleted.
    case itemDeleted = 86
    /// Login attempt failed, try to throttle response to possible attacker.
    case accountLoginDeniedThrottle = 87
    /// Two factor authentication (Steam Guard) code is incorrect.
    case twoFactorCodeMismatch = 88
    /// The activation code for two-factor authentication (Steam Guard) didn't match.
    case twoFactorActivationCodeMismatch = 89
    /// The current account has been associated with multiple partners.
    case accountAssociatedToMultiplePartners = 90
    /// The data has not been modified.
    case notModified = 91
    /// The account does not have a mobile device associated with it.
    case noMobileDevice = 92
    /// The time presented is out of range or tolerance.
    case timeNotSynced = 93
    /// SMS code failure - no match, none pending, etc.
    case smsCodeFailed = 94
    /// Too many accounts access this resource.
    case accountLimitExceeded = 95
    /// Too many changes to this account.
    case accountActivityLimitExceeded = 96
    /// Too many changes to this phone.
    case phoneActivityLimitExceeded = 97
    /// Cannot refund to payment method, must use wallet.
    case refundToWallet = 98
    /// Cannot send an email.
    case emailSendFailure = 99
    /// Can't perform operation until payment has settled.
    case notSettled = 100
    /// The user needs to provide a valid captcha.
    case needCaptcha = 101
    /// A game server login token owned by this token's owner has been banned.
    case gameServerLoginTokenDenied = 102
    /// Game server owner is denied for some other reason such as account locked, community ban, VAC ban,
    /// missing phone, etc.
    case gameServerOwnerDenied = 103
    /// The type of thing we were requested to act on is invalid.
    case invalidItemType = 104
    /// The IP address has been banned from taking this action.
    case ipBanned = 105
    /// This Game Server Login Token (GSLT) has expired from disuse; it can be reset for use.
    case gameServerLoginTokenExpired = 106
    /// User doesn't have enough wallet funds to complete the action.
    case insufficientFunds = 107
    /// There are too many of this thing pending already.
    case tooManyPending = 108
}
