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
            guard let account = account else { return dismiss() }
            if oldValue?.face != account.face {
                if let url = URL(string: account.face)?.inHttps {
                    let task = URLSession.shared.dataTask(with: url)
                    { [weak self] data,_,_ in
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
            if oldValue?.bCoins != account.bCoins {
                bCoinLabel.setText("B \(account.bCoins)")
            }
            if oldValue?.coins != account.coins {
                coinLabel.setText("币 \(account.coins)")
            }
            
            let oldInfo = oldValue?.level_info
            let info = account.level_info
            
            if oldInfo?.current_level != info.current_level {
                levelLabel.setText("LV\(info.current_level)")
            }
            
            let total = CGFloat(max(info.next_exp, 1))
            
            if oldInfo?.current_exp != info.current_exp {
                let width = CGFloat(info.current_exp) / total
                levelProgressBar.setRelativeWidth(width, withAdjustment: 0)
                levelCurrentLabel.setText("\(info.current_exp)")
            }
            
            if oldInfo?.next_exp != info.next_exp {
                levelNextLabel.setText("\(info.next_exp)")
            }
        }
    }
    
    override func willActivate() {
        super.willActivate()
        BKAccount.getCurrent { [weak self] in
            self?.account = $0
        }
    }
    
    @IBAction func logout() {
        BKSession.shared.logout()
        presentLoginControllerIfNeeded()
    }
}
