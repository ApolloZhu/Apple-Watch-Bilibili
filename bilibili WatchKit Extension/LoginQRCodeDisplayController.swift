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
    @IBOutlet var group: WKInterfaceGroup?
    @IBOutlet var checkMark: WKInterfaceImage?

    override func didAppear() {
        super.didAppear()
        BKLogin.login(handleLoginInfo: { info in
            DispatchQueue.global(qos: .userInteractive).async {
                guard let qrcode = QRCode(info.url, size: CGSize(width: 53, height: 53), colorDark: 0xFFFFFF, colorLight: 0),
                    let image = qrcode.image,
                    let data = UIImagePNGRepresentation(image)
                    else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.checkMark?.setImageData(data)
                }
            }
        }, handleLoginState: { state in
            DispatchQueue.main.async { [weak self] in
                switch state {
                case .succeeded, .expired: self?.dismiss()
                case .started: print("State: \(state)")
                case .needsConfirmation: self?.checkMark?.setImageNamed("Check Mark")
                default: fatalError("State: \(state)")
                }
            }
        })
    }
}
