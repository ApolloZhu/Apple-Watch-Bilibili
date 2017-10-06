//
//  BKCookie.swift
//  bilibili
//
//  Created by Apollo Zhu on 7/9/17.
//  Copyright © 2017 WWITDC. All rights reserved.
//

import Foundation

/// Cookie used to identify a bilibili user.
public struct BKCookie: Codable {
    /// DedeUserID
    private let mid: Int
    /// DedeUserID__ckMd5
    private let md5Sum: String
    /// SESSDATA, has some sort of expiration date.
    private let sessionData: String
    
    /// Keys to use when encoding to other formats
    ///
    /// - mid: DedeUserID
    /// - md5Sum: DedeUserID__ckMd5
    /// - sessionData: SESSDATA
    enum CodingKeys: String, CodingKey {
        case mid = "DedeUserID"
        case md5Sum = "DedeUserID__ckMd5"
        case sessionData = "SESSDATA"
    }
    
    /// Initialize a S2BCookie with required cookie value,
    /// available after login a bilibili account.
    ///
    /// - Parameters:
    ///   - DedeUserID: user's mid assigned by bilibili
    ///   - DedeUserID__ckMd5: md5 sum calculated by bilibili
    ///   - SESSDATA: some session data saved by bilibili
    public init(DedeUserID: Int, DedeUserID__ckMd5: String, SESSDATA: String) {
        mid = DedeUserID
        md5Sum = DedeUserID__ckMd5
        sessionData = SESSDATA
    }
    
    public init?(cookies: String) {
        var dict = [String:String]()
        for part in cookies
            .split(separator: ";") {
                let parts = part
                    .split(separator: "=")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                if parts.count == 2 { dict[parts[0]] = parts[1] }
        }
        guard let str = dict[CodingKeys.mid.stringValue],
            let mid = Int(str),
            let sum = dict[CodingKeys.md5Sum.stringValue],
            let data = dict[CodingKeys.sessionData.stringValue]
            else { return nil }
        self.init(DedeUserID: mid, DedeUserID__ckMd5: sum, SESSDATA: data)
    }
    
    public var valueForHeaderFieldCookie: String {
        return "\(CodingKeys.mid.stringValue)=\(mid);\(CodingKeys.md5Sum.stringValue)=\(md5Sum);\(CodingKeys.sessionData.stringValue)=\(sessionData)"
    }
}
