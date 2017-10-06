//
//  LoginQRCodeDisplayController.swift
//  bilibili WatchKit Extension
//
//  Created by Apollo Zhu on 10/5/17.
//  Copyright © 2017 Apollo Zhu. All rights reserved.
//

import UIKit
import WatchKit
import swift_qrcodejs

class LoginQRCodeDisplayController: WKInterfaceController {
    public static let name = "LoginViewController"
    
    @IBOutlet private var image: WKInterfaceImage!

    override func didAppear() {
        super.didAppear()
        BKLogin.login(handleLoginInfo: { info in
            DispatchQueue.global(qos: .userInteractive).async {
                let device = WKInterfaceDevice.current()
                let scale: CGFloat = 1
                var size = device.screenBounds.size
                size.width *= scale
                size.height *= scale
                // let scale = device.screenScale
                guard let qrcode = QRCode(info.url,
                                          size: size),
                    let image = qrcode.image
                    else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.image.setImage(image)
                }
            }
        }, handleLoginState: { state in
            DispatchQueue.main.async { [weak self] in
                switch state {
                case .succeeded, .expired: self?.dismiss()
                case .started: print("State: \(state)")
                case .needsConfirmation: self?.image.setImage(#imageLiteral(resourceName: "Check Mark"))
                default: fatalError("State: \(state)")
                }
            }
        })
    }
}
