//
//  main.swift
//  ChomiumCredentialReader
//
//  Created by LiYanan2004 on 2022/12/4.
//

import Foundation

@main
struct ChomiumCredentialReader {
    static func main() throws {
        let browser = ChromiumBrowser.chrome

        print("Hacking programme started...")
        print("")

        print("------------------ Cookies ------------------")
        try browser.printCookies(hideContent: false)

        print("")
        print("------------------ Login Data ------------------")
        try browser.printLoginData(hideContent: false)

        print("")
        print("Done.")
    }
}

