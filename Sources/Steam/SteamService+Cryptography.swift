import CryptoSwift
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
    enum SessionKeyError: Error {
        case failedToGenerateUnencryptedData
    }

    func makeSessionEncryptionData() throws -> EncryptionData {
        guard let keyData = Data(randomByteCount: 32) else {
            throw SessionKeyError.failedToGenerateUnencryptedData
        }

        return EncryptionData(keyData)
    }

    func encryptSessionKey(plainKeyData: Data, hmac: Data) throws -> Data {
        let publicKeyData = try SwKeyConvert.PublicKey.pemToPKCS1DER(Self.publicKey)
        let encryptedData = try CC.RSA.encrypt(
            plainKeyData + hmac,
            derKey: publicKeyData,
            tag: Data(),
            padding: .oaep,
            digest: .sha1
        )

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
        let data: [UInt8] = prefix.bytes + input.bytes
        let hmac = try HMAC(key: hmacSecret.bytes, variant: .sha1).authenticate(data)
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
    let hmac = try HMAC(key: hmacSecret.bytes, variant: .sha1).authenticate(iv.suffix(3) + message)

    if iv.prefix(13) != hmac.prefix(13) {
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
