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
            let raw = account.face
                .replacingOccurrences(of: "http://", with: "https://")
            if let url = URL(string: raw) {
                let task = URLSession.shared.dataTask(with: url)
                { [weak self] data,_,_ in
                    if let data = data {
                        self?.face?.setImageData(data)
                    }
                }
                task.resume()
            }
            uname.setText(account.uname)
            bCoinLabel.setText("B \(account.bCoins)")
            coinLabel.setText("币 \(account.coins)")
            let info = account.level_info
            let total = CGFloat(max(info.next_exp, 1))
            let width = CGFloat(info.current_exp) / total
            levelProgressBar.setRelativeWidth(width, withAdjustment: 0)
            levelLabel.setText("LV\(info.current_level)")
            levelCurrentLabel.setText("\(info.current_exp)")
            levelNextLabel.setText("\(info.next_exp)")
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        BKAccount.getCurrent { [weak self] in
            self?.account = $0
        }
    }
    
    @IBAction func logout() {
        BKSession.shared.logout()
        presentLoginControllerIfNeeded()
    }
}
