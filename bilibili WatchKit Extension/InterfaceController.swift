//
//  InterfaceController.swift
//  bilibili WatchKit Extension
//
//  Created by Apollo Zhu on 9/30/17.
//  Copyright © 2017 Apollo Zhu. All rights reserved.
//

import WatchKit
import Foundation
import BilibiliKit

class InterfaceController: WKInterfaceController, Named {
    public static let name = "MainViewController"
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if !BKSession.shared.isLoggedIn {
            WKInterfaceController.reloadRootPageControllers(withNames: [LoginQRCodeDisplayController.name], contexts: nil, orientation: .horizontal, pageIndex: 0)
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
