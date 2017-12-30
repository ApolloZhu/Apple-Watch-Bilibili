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
import BilibiliKit

extension WKInterfaceController {
    func presentLoginControllerIfNeeded() {
        if BKSession.shared.isLoggedIn { return }
        WKInterfaceController.reloadRootPageControllers(withNames: [LoginQRCodeDisplayController.name], contexts: nil, orientation: .horizontal, pageIndex: 0)
    }
}

class LoginQRCodeDisplayController: WKInterfaceController, Named {
    public static let name = "LoginViewController"
    @IBOutlet private var imageView: WKInterfaceImage!
    @IBOutlet private var waitingIndicator: WKInterfaceImage!

    private func login() {
        imageView?.setImage(nil)
        becomeCurrentPage()
        BKLoginHelper.default.login(handleLoginInfo: handleLoginInfo,
                                    handleLoginState: handleLoginState)
    }

    private func handleLoginInfo(_ info: BKLoginHelper.LoginURL) {
        DispatchQueue.global(qos: .userInteractive).async {
            [size = contentFrame.size] in
            guard let qrcode = QRCode(info.url, size: size,
                                      colorDark: 0xFFFFFF, colorLight: 0),
                let image = qrcode.image else { return }
            DispatchQueue.main.async { [weak self] in
                guard let imageView = self?.imageView else { return }
                self?.waitingIndicator?.setHidden(true)
                imageView.setImage(image)
                imageView.setHidden(false)
            }
        }
    }

    private func handleLoginState(_ state: BKLoginHelper.LoginState) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            switch state {
            case .started: print("State: \(state)")
            case .needsConfirmation:
                self.waitingIndicator.setImageNamed("waiting")
                self.waitingIndicator.startAnimatingWithImages(in: NSRange(0...26), duration: 3, repeatCount: -1)
                self.waitingIndicator.setHidden(false)
                self.imageView.setHidden(true)
            case .succeeded: self.loggedIn()
            case .expired: self.login()
            case .errored:
                let yes = WKAlertAction(title: "OK", style: .default) { [weak self] in self?.login() }
                let no = WKAlertAction(title: "No", style: .destructive) { exit(0) }
                self.presentAlert(withTitle: "Oops", message: "Something went wrong. Try again?", preferredStyle: .sideBySideButtonsAlert, actions: [no, yes])
            case .missingOAuthKey:
                let action = WKAlertAction(title: "OK", style: .default) { exit(0) }
                self.presentAlert(withTitle: "Internal Error", message: "Please tell the app developer to fix OAuthKey", preferredStyle: .alert, actions: [action])
            case .unknown(let status):
                let action = WKAlertAction(title: "OK", style: .default) { exit(Int32(status)) }
                self.presentAlert(withTitle: "Unknown Error", message: "Send this number to the app developer: \(status)", preferredStyle: .alert, actions: [action])
            }
        }
    }
    
    private func loggedIn() {
        presentNormalInterface()
    }

    override func willActivate() {
        super.willActivate()
        if BKSession.shared.isLoggedIn { return loggedIn() }
        WKExtension.shared().isAutorotating = true
        WKExtension.shared().isFrontmostTimeoutExtended = true
        login()
    }

    override func didDeactivate() {
        WKExtension.shared().isAutorotating = false
        WKExtension.shared().isFrontmostTimeoutExtended = false
    }
}
