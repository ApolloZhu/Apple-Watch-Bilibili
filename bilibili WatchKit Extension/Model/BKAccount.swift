//
//  BKAccount.swift
//  bilibili WatchKit Extension
//
//  Created by Apollo Zhu on 12/30/17.
//  Copyright © 2017 Apollo Zhu. All rights reserved.
//

import Foundation
import BilibiliKit

public struct BKAccount: Codable {
    public let level_info: LevelInfo
    public let face: String // URL
    public let uname: String
    /// 硬币
    public let money: Double
    /// B 币
    public let wallet: Wallet
    
    public struct Wallet: Codable, Equatable {
        let bcoin_balance: Int
        let coupon_balance: Int
    }
    public struct LevelInfo: Codable {
        public let current_level: Int
        public let current_min: Int
        public let current_exp: Int
        /// Can be either an int of exp required to go to next level, or "--" if at max level.
        public let next_exp: _Either<Int, String>
    }
}

extension BKAccount {
    static func getCurrent(_ handler: @escaping (Result<BKAccount, BKError>) -> Void) {
        URLSession.get("https://api.bilibili.com/x/web-interface/nav",
                       unwrap: BKWrapperMessage<BKAccount>.self,
                       then: handler)
    }
}
