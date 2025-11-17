//
//  Crypto.swift
//  CookiesHacking
//
//  Created by Yanan Li on 2025/11/17.
//

import Foundation
import CryptoSwift
import CommonCrypto

let password = ""

/// Generate key chain from the password.
///
/// - parameters:
///     - password: password to encrypted
func pbkdf2(
    password: String,
    saltData: Data,
    keyByteCount: Int,
    prf: CCPseudoRandomAlgorithm,
    rounds: Int
) -> Data? {
    guard let passwordData = password.data(using: .utf8) else { return nil }
    var derivedKeyData = Data(repeating: 0, count: keyByteCount)
    let derivedCount = derivedKeyData.count
    let derivationStatus: Int32 = derivedKeyData.withUnsafeMutableBytes { derivedKeyBytes in
        let keyBuffer: UnsafeMutablePointer<UInt8> =
            derivedKeyBytes.baseAddress!.assumingMemoryBound(to: UInt8.self)
        return saltData.withUnsafeBytes { saltBytes -> Int32 in
            let saltBuffer: UnsafePointer<UInt8> = saltBytes.baseAddress!.assumingMemoryBound(to: UInt8.self)
            return CCKeyDerivationPBKDF(
                CCPBKDFAlgorithm(kCCPBKDF2),
                password,
                passwordData.count,
                saltBuffer,
                saltData.count,
                prf,
                UInt32(rounds),
                keyBuffer,
                derivedCount)
        }
    }
    return derivationStatus == kCCSuccess ? derivedKeyData : nil
}

/// Decrypt text from encrypted data.
func decrypt(from encryptedData: Data) -> String? {
    var encrypted: [UInt8] = []
    let count = encryptedData.count
    
    for i in min(count, 3) ..< count {
        encrypted.append(encryptedData.bytes[i])
    }
    
    var decrypted: [UInt8] = []
    let key = pbkdf2(password: password, saltData: "saltysalt".data(using: .utf8)!, keyByteCount: 16, prf: CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1), rounds: 1003)!
    let iv = "                ".bytes // 16 spaces
    
    do {
        decrypted = try AES(key: key.bytes, blockMode: CBC(iv: iv)).decrypt(encrypted)
    } catch {
        print("Fail")
    }
    return String(bytes: Data(decrypted), encoding: .utf8)
}
