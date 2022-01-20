//
//  AccountInterfaceController.swift
//  bilibili WatchKit Extension
//
//  Created by Apollo Zhu on 12/29/17.
//  Copyright © 2017 Apollo Zhu. All rights reserved.
//

import WatchKit
import BilibiliKit

class AccountInterfaceController: WKInterfaceController, Named {
    public static let name = "AccountController"
    @IBOutlet private var face: WKInterfaceImage!
    @IBOutlet private var uname: WKInterfaceLabel!
    @IBOutlet private var bCoinLabel: WKInterfaceLabel!
    @IBOutlet private var coinLabel: WKInterfaceLabel!
    @IBOutlet private var levelProgressBar: WKInterfaceSeparator!
    @IBOutlet private var levelLabel: WKInterfaceLabel!
    @IBOutlet private var levelCurrentLabel: WKInterfaceLabel!
    @IBOutlet private var levelNextLabel: WKInterfaceLabel!
    
    private var account: BKAccount? {
        didSet {
            guard let account = account else {
                DispatchQueue.main.async(execute: dismiss)
                return
            }
            if oldValue?.face != account.face {
                if let url = URL(string: account.face)?.inHTTPS {
                    let task = URLSession.shared.dataTask(with: url) {
                        [weak self] (data, _, _) in
                        if let data = data {
                            self?.face?.setImageData(data)
                        }
                    }
                    task.resume()
                }
            }
            if oldValue?.uname != account.uname {
                uname.setText(account.uname)
            }
            if oldValue?.wallet != account.wallet {
                let wallet = account.wallet
                bCoinLabel.setText("B \(wallet.bcoin_balance)")
            }
            if oldValue?.money != account.money {
                coinLabel.setText("币 \(account.money)")
            }
            
            let oldInfo = oldValue?.level_info
            let info = account.level_info
            
            if oldInfo?.current_level != info.current_level {
                levelLabel.setText("LV\(info.current_level)")
            }
            
            let total: CGFloat
            switch info.next_exp {
            case .left(let nextExp):
                levelNextLabel.setText("\(nextExp)")
                total = CGFloat(max(nextExp, 1))
            case .right(let string):
                levelNextLabel.setText(string)
                total = 1
            }
            
            if oldInfo?.current_exp != info.current_exp {
                let width = CGFloat(info.current_exp) / total
                levelProgressBar.setRelativeWidth(width, withAdjustment: 0)
                levelCurrentLabel.setText("\(info.current_exp)")
            }
        }
    }
    
    override func willActivate() {
        super.willActivate()
        BKAccount.getCurrent { [weak self] in
            switch $0 {
            case .success(let account):
                self?.account = account
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func logout() {
        BKSession.shared.logout()
        presentLoginControllerIfNeeded()
    }
}
