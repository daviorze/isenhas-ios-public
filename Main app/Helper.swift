//
//  WidgetKitHelper.swift
//  iSenhas
//
//  Created by Davi Orzechowski on 30/07/22.
//
//. TOTP global functions

import Foundation
import SwiftOTP

@objcMembers final class Helper: NSObject {
    class func create2faCode(secret: String, algorithm: String = "SHA1", digits: Int = 6, period: Int = 30) -> String? {
        guard let data = SwiftOTP.base32DecodeToData(secret) else { return nil }
        let algo: OTPAlgorithm = {
                switch algorithm {
                case "SHA1":
                        return .sha1
                case "SHA256":
                        return .sha256
                case "SHA512":
                        return .sha512
                default:
                    return .sha1
                }
        }()
        guard let totp: SwiftOTP.TOTP = SwiftOTP.TOTP(secret: data, digits: digits, timeInterval: period, algorithm: algo) else { return nil }
        guard let totpText: String = totp.generate(time: Date()) else { return nil }
        return totpText
    }
}
//For 2 Factor Authentication
struct Token: Hashable, Identifiable {
        let id: String
        let uri: String
        let type: TokenType
        let issuerPrefix: String?
        let accountName: String?
        let secret: String
        let issuer: String?
        let algorithm: String
        let digits: Int
        let period: Int
        var displayIssuer: String
        var displayAccountName: String
        
        init?(uri: String) {
                guard let url: URL = URL(string: uri) else { return nil }
                guard let components: URLComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
                guard components.scheme == "otpauth" else { return nil }
                guard components.host == "totp" else { return nil }
                guard let queryItems: [URLQueryItem] = components.queryItems else { return nil }
                
                guard let secretParameter: URLQueryItem = queryItems.filter({ $0.name.lowercased() == "secret" }).first else { return nil }
                guard let secretValue: String = secretParameter.value else { return nil }
                guard Helper.create2faCode(secret: secretValue) != nil else { return nil }
                self.secret = secretValue
                
                if let issuerParameter: URLQueryItem = queryItems.filter({ $0.name.lowercased() == "issuer" }).first {
                        self.issuer = issuerParameter.value
                } else {
                        self.issuer = nil
                }
                
                if let algorithmParameter: URLQueryItem = queryItems.filter( { $0.name.lowercased() == "algorithm" }).first {
                        switch (algorithmParameter.value ?? "SHA1").uppercased() {
                        case "SHA1":
                                self.algorithm = "SHA1"
                        case "SHA256":
                                self.algorithm = "SHA256"
                        case "SHA512":
                                self.algorithm = "SHA512"
                        default:
                                self.algorithm = "SHA1"
                        }
                } else {
                        self.algorithm = "SHA1"
                }
                
                if let digitsParameter: URLQueryItem = queryItems.filter( { $0.name.lowercased() == "digits" }).first {
                        switch digitsParameter.value ?? "6" {
                        case "7":
                                self.digits = 7
                        case "8":
                                self.digits = 8
                        default:
                                self.digits = 6
                        }
                } else {
                        self.digits = 6
                }
                
                if let periodValue: String = queryItems.filter( { $0.name.lowercased() == "period" }).first?.value {
                        if let periodNumber = Int(periodValue) {
                                self.period = periodNumber > 0 ? periodNumber : 30
                        } else {
                                self.period = 30
                        }
                } else {
                        self.period = 30
                }
                
                var path: String = components.path
                while path.hasPrefix("/") {
                        path = String(path[path.index(path.startIndex, offsetBy: 1)...])
                }
                let pathcomponents: [String] = path.components(separatedBy: ":")
                switch pathcomponents.count {
                case 0:
                        issuerPrefix = nil
                        accountName = nil
                case 1:
                        issuerPrefix = nil
                        accountName = pathcomponents[0]
                case 2:
                        issuerPrefix = pathcomponents[0]
                        accountName = pathcomponents[1]
                default:
                        issuerPrefix = nil
                        accountName = nil
                }
                self.uri = uri
                self.type = .totp
                self.displayIssuer = self.issuerPrefix ?? ""
                self.displayAccountName = self.accountName ?? ""
                self.id = self.secret + Date().timeIntervalSince1970.description
                
                if self.displayIssuer.isEmpty && self.issuer.hasContent {
                        self.displayIssuer = issuer!
                }
        }
        enum TokenType {
                case totp
        }

        enum Algorithm: String {
                case sha1 = "SHA1"
                case sha256 = "SHA256"
                case sha512 = "SHA512"
        }
}
extension Optional where Wrapped == String {

        /// Not nil && not empty
        var hasContent: Bool {
                switch self {
                case .none:
                        return false
                case .some(let value):
                        return !value.isEmpty
                }
        }
}
