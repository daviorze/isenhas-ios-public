//
//  WidgetKitHelper.swift
//  Passwords
//
//  Created by Davi Orzechowski on 30/07/22.
//
//  Functions used in main app

import WidgetKit
import Foundation
import SwiftUI
import TipKit
import CryptoKit
import CommonCrypto
import Security
import LocalAuthentication
@objcMembers final class SwiftHelper: NSObject {
    class func keyFromReadable(_ readableKey: String) -> SymmetricKey {
        let cleaned = readableKey.replacingOccurrences(of: "-", with: "")
        let charset = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        
        var keyBytes: [UInt8] = []
        for char in cleaned {
            if let idx = charset.firstIndex(of: char) {
                keyBytes.append(UInt8(idx))
            }
        }
        if keyBytes.count > 32 {
            keyBytes = Array(keyBytes.prefix(32))
        } else if keyBytes.count < 32 {
            keyBytes.append(contentsOf: repeatElement(0, count: 32 - keyBytes.count))
        }
        
        return SymmetricKey(data: Data(keyBytes))
    }
    class func extremeEncrypt(_ message: String,_ readableKey: String) -> String? {
        let key = SwiftHelper.keyFromReadable(readableKey)
        let nonce = AES.GCM.Nonce()
        
        do {
            let sealedBox = try AES.GCM.seal(message.data(using: .utf8)!, using: key, nonce: nonce)
            var data = Data()
            data.append(contentsOf: sealedBox.nonce)
            data.append(sealedBox.ciphertext)
            data.append(sealedBox.tag)
            
            return data.base64EncodedString()
        } catch {
            print("Erro ao criptografar:", error)
            return nil
        }
    }
    class func extremeDecrypt(_ encryptedBase64:String, _ readableKey: String) -> String? {
        guard let encrypted = Data(base64Encoded: encryptedBase64) else { return nil }
        let key = SwiftHelper.keyFromReadable(readableKey)
        print("IV hex:", encrypted.prefix(12).map { String(format: "%02x", $0) })
        print("Ciphertext hex:", encrypted.dropFirst(12).dropLast(16).map { String(format: "%02x", $0) })
        print("Tag hex:", encrypted.suffix(16).map { String(format: "%02x", $0) })
        do {
            let nonce = try AES.GCM.Nonce(data: encrypted.prefix(12))
            let tag = encrypted.suffix(16)
            let ciphertext = encrypted.dropFirst(12).dropLast(16)
            
            let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext, tag: tag)
            let decrypted = try AES.GCM.open(sealedBox, using: key)
            return String(data: decrypted, encoding: .utf8)
        } catch {
            print("Erro ao descriptografar:", error)
            return nil
        }
    }
    /*Key for local encryption derivated of Master password*/
    class func deriveKeyPBKDF2(password: String, salt: Data, iterations: Int = 200_000) -> Data {
        let passwordData = Data(password.utf8)

        let keyLength = 32 // 32 bytes = AES-256
        var derivedKey = Data(count: keyLength)

        let result = derivedKey.withUnsafeMutableBytes { derivedKeyBytes in
            salt.withUnsafeBytes { saltBytes in
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    password, passwordData.count,
                    saltBytes.bindMemory(to: UInt8.self).baseAddress!, salt.count,
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                    UInt32(iterations),
                    derivedKeyBytes.bindMemory(to: UInt8.self).baseAddress!, keyLength
                )
            }
        }

        guard result == kCCSuccess else {
            return Data()
        }
        
        return derivedKey
    }
    class func randomSalt(length: Int = 16) -> Data {
        var data = Data(count: length)
        _ = data.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!)
        }
        return data
    }
    enum KeychainError: Error {
        case unableToCreateAccessControl
        case unexpectedStatus(OSStatus)
    }
    
    class func saveVaultKeyToKeychain(key: Data) {
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "example.key",
            kSecAttrAccount as String: "example"
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        var error: Unmanaged<CFError>?
        guard let accessControl = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            [.userPresence],
            &error
        ) else {
            return
        }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "example.key",
            kSecAttrAccount as String: "example",
            kSecValueData as String: key,
            kSecAttrAccessControl as String: accessControl,
            kSecUseAuthenticationUI as String: kSecUseAuthenticationUIAllow
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("Erro ao salvar no Keychain:", status)
            return
        }
    }
    class func loadVaultKeyFromKeychain(context: LAContext) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "example.key",
            kSecAttrAccount as String: "example",
            kSecReturnData as String: true,
            kSecUseAuthenticationContext as String: context
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            return nil
        }

        return item as? Data
    }
    class func vaultKeyExistsInKeychain(account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "example.key",
            kSecAttrAccount as String: account,
            kSecReturnAttributes as String: false,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseAuthenticationUI as String: kSecUseAuthenticationUIFail
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)

        if status == errSecSuccess {
            return true
        }
        
        if status == errSecInteractionNotAllowed {
            // Exist but protected with biometry
            return true
        }
        
        if status == errSecItemNotFound {
            return false
        }
        
        return false
    }
    /*Local encryption*/
    class func encryptStringAES(_ plaintext: String) -> String {
        /*encryptionKey loaded in Login.swift from Keychain*/
        if(globals.encryptionKey == nil){
            return plaintext
        }
        guard globals.encryptionKey!.count == 32 else {
            return plaintext
        }
        let key = SymmetricKey(data: globals.encryptionKey!)
        let data = Data(plaintext.utf8)
        do{
            let sealedBox = try AES.GCM.seal(data, using: key)
            
            guard let combined = sealedBox.combined else {
                return ""
            }            
            return combined.base64EncodedString()
        } catch {
            return ""
        }
    }
    class func decryptStringAES(_ base64Ciphertext: String) -> String {
        /*encryptionKey loaded in Login.swift from Keychain*/
        if(globals.encryptionKey == nil){
            return base64Ciphertext
        }
        guard globals.encryptionKey!.count == 32 else {
            return base64Ciphertext
        }

        guard let combinedData = Data(base64Encoded: base64Ciphertext) else {
            return ""
        }
        do{
            let key = SymmetricKey(data: globals.encryptionKey!)
            let sealedBox = try AES.GCM.SealedBox(combined: combinedData)
            
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            
            guard let plaintext = String(data: decryptedData, encoding: .utf8) else {
                return ""
            }
            
            return plaintext
        } catch {
            return ""
        }
    }
    /*Save local storage*/
    class func saveDatabase(_ dicionario: NSMutableDictionary) {
        if let passwords = dicionario["passwords"] as? NSMutableArray {
            let encrypted = encryptPasswordsArray(passwords)
            dicionario["passwords"] = encrypted
        }
        if let vaults = dicionario["vaults"] as? NSMutableArray {
            let encryptedVaults = encryptVaultsArray(vaults)
            dicionario["vaults"] = encryptedVaults
        }
        if(dicionario["userToken"] != nil){
            let encrypted = dicionario["userToken"] as? String ?? ""
            dicionario["userToken"] = encryptStringAES(encrypted)
        }
        if(dicionario["recoveryKey"] != nil){
            let encrypted = dicionario["recoveryKey"] as? String ?? ""
            dicionario["recoveryKey"] = encryptStringAES(encrypted)
        }
        if(dicionario["aesKey"] != nil){
            let encrypted = dicionario["aesKey"] as? String ?? ""
            dicionario["aesKey"] = encryptStringAES(encrypted)
        }
        if(dicionario["userid"] != nil){
            let encrypted = dicionario["userid"] as? String ?? ""
            dicionario["userid"] = encryptStringAES(encrypted)
        }
        let fileManager = FileManager.default
        guard let fileManagerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "example") else {
            print("Error")
            return
        }
        let documentsDirectory = fileManagerURL.path
        let plistName = "example.plist"
        let path = (documentsDirectory as NSString).appendingPathComponent(plistName)

        let success = dicionario.write(toFile: path, atomically: true)
        if !success {
            print("Error:", path)
        }
    }
    class func encryptPasswordsArray(_ passwords: NSMutableArray) -> NSMutableArray {
        let newArray = NSMutableArray()
        for i in 0..<passwords.count {
            guard let password = passwords[i] as? NSMutableDictionary else { continue }
            // password
            if let plain = password["password"] as? String {
                password["password"] = encryptStringAES(plain)
            }
            // old
            if let oldValue = password["old"] as? String, !oldValue.isEmpty {
                password["old"] = encryptStringAES(oldValue)
            }
            // name
            if let name = password["name"] as? String, !name.isEmpty {
                password["name"] = encryptStringAES(name)
            }
            // observation
            if let observation = password["observation"] as? String, !observation.isEmpty {
                password["observation"] = encryptStringAES(observation)
            }
            // userHandle
            if let userHandle = password["userHandle"] as? String, !userHandle.isEmpty {
                password["userHandle"] = encryptStringAES(userHandle)
            }
            // recordIdentifier
            if let recordIdentifier = password["recordIdentifier"] as? String, !recordIdentifier.isEmpty {
                password["recordIdentifier"] = encryptStringAES(recordIdentifier)
            }
            // credentialID
            if let credentialID = password["credentialID"] as? String, !credentialID.isEmpty {
                password["credentialID"] = encryptStringAES(credentialID)
            }
            // secret
            if let secret = password["secret"] as? String, !secret.isEmpty {
                password["secret"] = encryptStringAES(secret)
            }
            // algorithm
            if let algorithm = password["algorithm"] as? String, !algorithm.isEmpty {
                password["algorithm"] = encryptStringAES(algorithm)
            }
            // digits
            if let digits = password["digits"] as? String, !digits.isEmpty {
                password["digits"] = encryptStringAES(digits)
            }
            // period
            if let period = password["period"] as? String, !period.isEmpty {
                password["period"] = encryptStringAES(period)
            }
            // vaultid
            if let vaultid = password["vaultid"] as? String, !vaultid.isEmpty {
                password["vaultid"] = encryptStringAES(vaultid)
            }
            password["aes256"] = "ok"
            newArray.add(password)
        }
        return newArray
    }
    class func encryptVaultsArray(_ passwords: NSMutableArray) -> NSMutableArray {
        let newArray = NSMutableArray()
        for i in 0..<passwords.count {
            guard let password = passwords[i] as? NSMutableDictionary else { continue }
            if let name = password["name"] as? String, !name.isEmpty {
                password["name"] = encryptStringAES(name)
            }
            newArray.add(password)
        }
        return newArray
    }
    /*Read local storage*/
    class func readDatabase() -> NSMutableDictionary {
        let fileManager = FileManager.default
        guard let fileManagerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "example") else {
            return NSMutableDictionary()
        }
        let documentsDirectory = fileManagerURL.path
        let plistName = "example.plist"
        let path = (documentsDirectory as NSString).appendingPathComponent(plistName)
        if !fileManager.fileExists(atPath: path) {
            if let bundlePath = Bundle.main.path(forResource: "example", ofType: "plist") {
                do {
                    try fileManager.copyItem(atPath: bundlePath, toPath: path)
                } catch {
                    print("Error:", error)
                }
            }
        }
        let savedStock = NSMutableDictionary(contentsOfFile: path) ?? NSMutableDictionary()
        if let encryptedPasswords = savedStock["passwords"] as? NSMutableArray {
            savedStock["passwords"] = decryptPasswordsArray(encryptedPasswords)
        }
        if let encryptedVaults = savedStock["vaults"] as? NSMutableArray {
            savedStock["vaults"] = decryptVaultsArray(encryptedVaults)
        }
        if(savedStock["userToken"] != nil){
            let encrypted = savedStock["userToken"] as? String ?? ""
            savedStock["userToken"] = decryptStringAES(encrypted)
        }
        if(savedStock["recoveryKey"] != nil){
            let encrypted = savedStock["recoveryKey"] as? String ?? ""
            savedStock["recoveryKey"] = decryptStringAES(encrypted)
        }
        if(savedStock["aesKey"] != nil){
            let encrypted = savedStock["aesKey"] as? String ?? ""
            savedStock["aesKey"] = decryptStringAES(encrypted)
        }
        if(savedStock["userid"] != nil){
            let encrypted = savedStock["userid"] as? String ?? ""
            savedStock["userid"] = decryptStringAES(encrypted)
        }
        return savedStock
    }
    class func decryptVaultsArray(_ passwords: NSMutableArray) -> NSMutableArray {
        let newArray = NSMutableArray()
        for i in 0..<passwords.count {
            if let password = passwords[i] as? NSMutableDictionary {
                if let name = password["name"] as? String, !name.isEmpty {
                    password["name"] = decryptStringAES(name)
                }
                newArray.add(password)
            }
        }
        return newArray
    }
    class func decryptPasswordsArray(_ passwords: NSMutableArray) -> NSMutableArray {
        let newArray = NSMutableArray()
        for i in 0..<passwords.count {
            guard let password = passwords[i] as? NSMutableDictionary else { continue }

            if let encryptedPass = password["password"] as? String {
                password["password"] = decryptStringAES(encryptedPass)
            }
            if let oldValue = password["old"] as? String, !oldValue.isEmpty {
                password["old"] = decryptStringAES(oldValue)
            }
            if let name = password["name"] as? String, !name.isEmpty {
                password["name"] = decryptStringAES(name)
            }
            if let observation = password["observation"] as? String, !observation.isEmpty {
                password["observation"] = decryptStringAES(observation)
            }
            if let userHandle = password["userHandle"] as? String, !userHandle.isEmpty {
                password["userHandle"] = decryptStringAES(userHandle)
            }
            if let recordIdentifier = password["recordIdentifier"] as? String, !recordIdentifier.isEmpty {
                password["recordIdentifier"] = decryptStringAES(recordIdentifier)
            }
            if let credentialID = password["credentialID"] as? String, !credentialID.isEmpty {
                password["credentialID"] = decryptStringAES(credentialID)
            }
            if let secret = password["secret"] as? String, !secret.isEmpty {
                password["secret"] = decryptStringAES(secret)
            }
            if let algorithm = password["algorithm"] as? String, !algorithm.isEmpty {
                password["algorithm"] = decryptStringAES(algorithm)
            }
            if let digits = password["digits"] as? String, !digits.isEmpty {
                password["digits"] = decryptStringAES(digits)
            }
            if let period = password["period"] as? String, !period.isEmpty {
                password["period"] = decryptStringAES(period)
            }
            if let vaultid = password["vaultid"] as? String, !vaultid.isEmpty {
                password["vaultid"] = decryptStringAES(vaultid)
            }
            newArray.add(password)
        }
        return newArray
    }
    class func getRecoveryKey() -> String {
        let database = readDatabase()
        let encrypted = database["recoveryKey"] as? String 
        return encrypted
    }
    class func saveRecoveryKey(_ token: String) {
        let database = readDatabase()
        database["recoveryKey"] = token
        saveDatabase(database)
    }
}
