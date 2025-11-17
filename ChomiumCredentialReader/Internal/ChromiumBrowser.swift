//
//  ChromiumBrowser.swift
//  ChomiumCredentialReader
//
//  Created by Yanan Li on 2025/11/17.
//

import Foundation
import SQLite
import CryptoSwift

enum ChromiumBrowser: String {
    case chrome = "Google Chrome"
    case edge = "Microsoft Edge"
    
    /// Fetch cookies from Microsoft Edge.
    /// - parameters:
    ///     - hideContent: If `false`, all text will be printed, otherwise, middle part of the content will be replaced with '*'
    /// - warning: This should be used legally. Here is just for study, dont use it on the internet to hack others' data.
    func printCookies(hideContent: Bool = false) throws {
        let db = try Connection("\(NSHomeDirectory())/Library/Application Support/\(rawValue)/Default/Cookies")
        
        let cookies = Table("cookies")
        let hostKey = Expression<String>("host_key")
        let name = Expression<String>("name")
        let encryptedValue = Expression<Data?>("encrypted_value")

        for cookie in try db.prepare(cookies) {
            if let encryptedData = cookie[encryptedValue] {
                let prefixBytes = encryptedData.bytes.prefix(3)
                let header = String(bytes: Data(prefixBytes), encoding: .utf8)

                guard header == "v10" || header == "v11" else { continue }
                guard let cookieValue = decrypt(from: encryptedData) else { continue }
                
                let cookieHeader = cookieValue.prefix(8)
                let cookieTail = String(cookieValue.reversed().prefix(8).reversed())
                print("host: \(cookie[hostKey])\n\tname: \(cookie[name])\n\tvalue: \(hideContent ? "\(cookieHeader)...\(cookieTail)" : cookieValue)")
            }
        }
    }
    
    /// Fetch login data (saved user names and passwords)  from Microsoft Edge.
    /// - parameters:
    ///     - hideContent: If `false`, all text will be printed, otherwise, middle part of the content will be replaced with '*'
    /// - warning: This should be used legally. Here is just for study, dont use it on the internet to hack others' data.
    func printLoginData(hideContent: Bool = false) throws {
        let db = try Connection("\(NSHomeDirectory())/Library/Application Support/\(rawValue)/Default/Login Data")
    
        let logins = Table("logins")
        let hostKey = Expression<String>("host_key")
        let userName = Expression<String>("username_value")
        let encryptedValue = Expression<Data?>("password_value")

        for login in try db.prepare(logins) {
            if let encryptedData = login[encryptedValue] {
                let prefixBytes = encryptedData.bytes.prefix(3)
                let header = String(bytes: Data(prefixBytes), encoding: .utf8)

                guard header == "v10" || header == "v11" else { continue }
                guard let password = decrypt(from: encryptedData) else { continue }
                
                let passwordHeader = password.prefix(2)
                let passwordTail = String(password.reversed().prefix(2).reversed())
                print("Host: \(logins[hostKey])")
                print("userName: \(hideContent ? String(login[userName].prefix(3)) : login[userName])\(hideContent ? "..." : "")\n\tpassword: \(hideContent ? "\(passwordHeader)...\(passwordTail)" : password)")
            }
        }
    }
}
