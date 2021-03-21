//
//  SteamService+Login.swift
//  
//  Copyright © 2021 Sebastian Jachec. All rights reserved.
//

import Combine
import Foundation

extension SteamService {
    public enum Credentials {
        /// - remember: If `true`,  login key will be generated upon successful login, which can be used instead of a password
        /// for subsequent logins.
        case password(String, remember: Bool = false)
        case loginKey(String)
    }

    public enum SteamGuard {
        case none
        /// Request that a Steam Guard code be delivered via the user's previously chosen method (email or Steam app).
        case requestCode
        case emailCode(String)
        case mobileCode(String)
    }

    public enum LoginError: Error {
        /// A connection to a Steam server has not been established.
        /// Use `connect` to establish a connection before logging into a Steam user account.
        case disconnected
        case missingUsername
        case failedToEncode
        case initiation(Error)
        /// The response received from the server could not be parsed.
        case failedToParseResponse
        /// A Steam identifier was not received for the user.
        case missingIdentifier
        /// An email address was not received for the user.
        case missingEmail
        /// Account info was not received for the user.
        case missingAccountInfo
        case steamError(SteamResult)
        case other(Error)
        case unknown
    }

    /// Login to an existing Steam user account.
    ///
    /// If the user's Steam account has 2FA enabled and a password has been supplied in `credentials`, a new OTP code will be delivered
    /// to the user's email address or be presented from the Steam mobile app, and this `login` call will fail
    /// with `accountLoginDeniedNeedTwoFactor`. Repeat the call, providing `SteamGuard.emailCode`
    /// or `SteamGuard.mobileCode` as appropriate with the user's code to complete the login process.
    public func login(
        username: String,
        credentials: Credentials,
        steamGuard: SteamGuard) -> AnyPublisher<SteamLoginResponse, LoginError>
    {
        guard connection != nil else {
            return Fail(error: LoginError.disconnected).eraseToAnyPublisher()
        }

        guard !username.isEmpty else {
            return Fail(error: LoginError.missingUsername).eraseToAnyPublisher()
        }

        var logon = CMsgClientLogon()
        logon.accountName = username

        switch credentials {
        case let .password(password, _):
            logon.password = password
        case let .loginKey(key):
            logon.loginKey = key
        }

        switch steamGuard {
        case let .emailCode(code):
            logon.authCode = code
        case let .mobileCode(code):
            logon.twoFactorCode = code
        case .none, .requestCode:
            break
        }

        if case let .password(_, rememberPassword) = credentials {
            logon.shouldRememberPassword = rememberPassword
        }

        logon.protocolVersion = 65580
        logon.eresultSentryfile = Int32(SteamResult.fileNotFound.rawValue)
        logon.supportsRateLimitResponse = true
        logon.chatMode = ChatMode.default.rawValue

        guard let payload = try? logon.serializedData() else {
            return Fail(error: LoginError.failedToEncode).eraseToAnyPublisher()
        }

        var headerContent = CMsgProtoBufHeader()
        headerContent.steamid = SteamIdentifier().rawValue

        let message = ProtobufMessage(
            header: .init(messageType: .kEmsgClientLogon, content: headerContent),
            payload: payload)

        let response = messages.first(where: { $0.type == .kEmsgClientLogOnResponse })
            .setFailureType(to: LoginError.self)
            .flatMap { message -> AnyPublisher<SteamLoginResponse, LoginError> in
                guard
                    let response = try? CMsgClientLogonResponse(serializedData: message.payload),
                    let result = SteamResult(rawValue: UInt32(response.eresult)) else
                {
                    return Fail(error: LoginError.failedToParseResponse).eraseToAnyPublisher()
                }

                guard result == .success else {
                    return Fail(error: LoginError.steamError(result)).eraseToAnyPublisher()
                }

                guard let identifier = SteamIdentifier(response.clientSuppliedSteamid) else {
                    return Fail(error: LoginError.missingIdentifier).eraseToAnyPublisher()
                }

                let accountFlags = SteamAccountFlags(rawValue: response.accountFlags)
                let vanityURLSuffix = response.hasVanityURL ? response.vanityURL : nil

                switch credentials {
                case .password(_, false), .loginKey:
                    let response = SteamLoginResponse(
                        loginKey: nil,
                        steamIdentifier: identifier,
                        accountFlags: accountFlags,
                        vanityProfileURLSuffix: vanityURLSuffix)
                    return Just(response).setFailureType(to: LoginError.self).eraseToAnyPublisher()

                case .password(_, true):
                    return self.messages.first(where: { $0.type == .kEmsgClientNewLoginKey })
                        .tryMap { message in
                            let loginKey: String?
                            if let loginKeyResponse = try? CMsgClientNewLoginKey(serializedData: message.payload) {
                                loginKey = loginKeyResponse.loginKey
                            } else {
                                loginKey = nil
                            }

                            return SteamLoginResponse(
                                loginKey: loginKey,
                                steamIdentifier: identifier,
                                accountFlags: accountFlags,
                                vanityProfileURLSuffix: vanityURLSuffix)
                        }
                        .mapError {
                            $0 as? LoginError ?? LoginError.other($0)
                        }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()

        return send(message)
            .mapError(LoginError.initiation)
            .flatMap { response }
            .eraseToAnyPublisher()
    }

    /// Log out of the currently logged-in Steam user account and end the connection.
    /// To begin the login process again, call `connect` first.
    public func logout() -> AnyPublisher<Void, SendError> {
        let message = ProtobufMessage(header: .init(messageType: .kEmsgClientLogOff), payload: Data())
        return send(message)
    }
}
