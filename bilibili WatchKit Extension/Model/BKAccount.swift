//
//  BKAccount.swift
//  bilibili WatchKit Extension
//
//  Created by Apollo Zhu on 12/30/17.
//  Copyright © 2017 Apollo Zhu. All rights reserved.
//

import BilibiliKit

public struct BKAccount: Codable {
    public let level_info: LevelInfo
    public let bCoins: Double
    public let coins: Double
    public let face: String // URL
    // let nameplate_current: URL
    // let pendant_current: Any
    public let uname: String
    // let userStatus: Any
    // let vipType: Int
    // let vipStatus: Int
    // let official_verify: Int
    // let pointBalance: Int
    public struct LevelInfo: Codable {
        public let current_level: Int
        public let current_min: Int
        public let current_exp: Int
        public let next_exp: Int
    }
}

extension BKAccount {
    // Alternate: https://api.bilibili.com/x/web-interface/nav
    static let url: URL = "https://account.bilibili.com/home/userInfo"
    static func getCurrent(_ handler: @escaping (BKAccount?) -> Void) {
        struct Wrapper: Codable {
            let code: Int
            let status: Bool
            let data: BKAccount
        }
        let request = BKSession.shared.request(to: url)
        let task = URLSession.shared.dataTask(with: request) { data, res, err in
            guard let data = data else { return handler(nil) }
            let wrapped = try? JSONDecoder().decode(Wrapper.self, from: data)
            handler(wrapped?.data)
        }
        task.resume()
    }
}
