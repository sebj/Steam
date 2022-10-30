public struct SteamLoginResponse: Hashable, Equatable {

    /// If the `remember` flag was previously set for the login request, this is a key that can be persisted
    /// and used to log the user in without their credentials,
    public let loginKey: String?

    public let steamIdentifier: SteamIdentifier

    public let accountFlags: SteamAccountFlags

    /// The suffix for the user's vanity profile URL, if it has been set. (https://steamcommunity.com/id/...)
    public let vanityProfileURLSuffix: String?
}
