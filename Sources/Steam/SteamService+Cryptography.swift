//
//  SteamService+Cryptography.swift
//
//  Copyright © 2021 Sebastian Jachec. All rights reserved.
//

import CryptoSwift
import CryptoKit
import Foundation
import SwCrypt

extension SteamService {
    enum SessionEncryption {
        case unencrypted
        case inProgress(EncryptionData)
        case encrypted(EncryptionData)
    }
}

// MARK: - Session Key

extension SteamService {
    func makeSessionEncryptionData() -> EncryptionData {
        let keyData = SymmetricKey(size: .bits256).withUnsafeBytes { body in
            Data(body)
        }

        return EncryptionData(keyData)
    }

    func encryptSessionKey(plainKeyData: Data, hmac: Data) throws -> Data {
        let publicKeyData = try SwKeyConvert.PublicKey.pemToPKCS1DER(Self.publicKey)
        let encryptedData = try CC.RSA.encrypt(plainKeyData + hmac, derKey: publicKeyData, tag: Data(), padding: .oaep, digest: .sha1)

        return encryptedData
    }

    // SteamWorks Public Key
    private static let publicKey =
        """
        -----BEGIN PUBLIC KEY-----
        MIGdMA0GCSqGSIb3DQEBAQUAA4GLADCBhwKBgQDf7BrWLBBmLBc1OhSwfFkRf53T
        2Ct64+AVzRkeRuh7h3SiGEYxqQMUeYKO6UWiSRKpI2hzic9pobFhRr3Bvr/WARvY
        gdTckPv+T1JzZsuVcNfFjrocejN1oWI0Rrtgt4Bo+hOneoo3S57G9F1fOpn5nsQ6
        6WOiu4gZKODnFMBCiQIBEQ==
        -----END PUBLIC KEY-----
        """
}

// MARK: -

extension SteamService {
    func symmetricEncrypt(_ input: Data, key: Data, hmacSecret: Data) throws -> [UInt8] {
        let prefix = Data(randomByteCount: 3)!
        let hmacKey = SymmetricKey(data: hmacSecret)
        let hmac = CryptoKit.HMAC<CryptoKit.Insecure.SHA1>.authenticationCode(for: prefix + input, using: hmacKey)
        let iv = hmac.prefix(13) + prefix
        return try symmetricEncrypt(input, key: key, iv: Data(iv))
    }

    private func symmetricEncrypt(_ input: Data, key: Data, iv: Data) throws -> [UInt8] {
        let aesIV = try AES(key: key.bytes, blockMode: ECB(), padding: .noPadding)
        let encryptedIV = try aesIV.encrypt(iv.bytes)

        let ciphertext = try AES(key: key.bytes, blockMode: CBC(iv: iv.bytes)).encrypt(input.bytes)

        return encryptedIV + ciphertext
    }
}

// MARK: - Decryption

enum DecryptError: Error {
    case hmacDoesNotMatch
}

func symmetricDecrypt(_ input: Data, key: Data, hmacSecret: Data) throws -> [UInt8] {
    let iv = try AES(key: key.bytes, blockMode: ECB()).decrypt(input.prefix(16).bytes)
    let message = try symmetricDecrypt(input, key: key, iv: Data(iv))
    
    let hmacKey = SymmetricKey(data: hmacSecret)
    let hmac = CryptoKit.HMAC<CryptoKit.Insecure.SHA1>.authenticationCode(for: iv.suffix(3) + message, using: hmacKey)
    
    if iv.prefix(13) != Array(Data(hmac)).prefix(13) {
        throw DecryptError.hmacDoesNotMatch
    }

    return message
}

private func symmetricDecrypt(_ data: Data, key: Data, iv: Data) throws -> [UInt8] {
    let cipherText = data.bytes.dropFirst(iv.count)
    return try AES(key: key.bytes, blockMode: CBC(iv: iv.bytes)).decrypt(cipherText)
}

// MARK: - 

private extension Data {
    init?(randomByteCount: Int) {
        var keyData = Data(count: randomByteCount)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, randomByteCount, $0.baseAddress!)
        }

        guard result == errSecSuccess else {
            return nil
        }

        self = keyData
    }
}
