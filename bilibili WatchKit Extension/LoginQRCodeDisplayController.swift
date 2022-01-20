//
//  LoginQRCodeDisplayController.swift
//  bilibili WatchKit Extension
//
//  Created by Apollo Zhu on 10/5/17.
//  Copyright © 2017 Apollo Zhu. All rights reserved.
//

import UIKit
import WatchKit
import EFQRCode
import BilibiliKit

extension WKInterfaceController {
    func presentLoginControllerIfNeeded() {
        if BKSession.shared.isLoggedIn {
            // FIXME: present the account info view for now
            return presentNormalInterface()
        }
        WKInterfaceController.reloadRootPageControllers(withNames: [LoginQRCodeDisplayController.name], contexts: nil, orientation: .horizontal, pageIndex: 0)
    }
}

class LoginQRCodeDisplayController: WKInterfaceController, Named {
    public static let name = "LoginViewController"
    @IBOutlet private var imageView: WKInterfaceImage!
    @IBOutlet private var waitingIndicator: WKInterfaceImage!
    private var isLoginInProcess = false
    
    private func login(anyways: Bool = false) {
        guard anyways || !isLoginInProcess else { return }
        isLoginInProcess = true
        imageView?.setImageNamed("Akari")
        
        BKSession.shared.login(handleLoginInfo: handleLoginInfo,
                               handleLoginState: handleLoginState)
    }
    
    private func handleLoginInfo(_ info: BKSession.QRCodeLoginHelper.LoginURL) {
        DispatchQueue.global(qos: .userInteractive).async {
            guard let image = EFQRCode.generate(for: info.url,
                                                backgroundColor: .white()!,
                                                foregroundColor: .black()!)
            else { return }
            DispatchQueue.main.async { [weak self] in
                guard let imageView = self?.imageView else { return }
                self?.waitingIndicator?.setHidden(true)
                imageView.setImage(UIImage(cgImage: image))
                imageView.setHidden(false)
            }
        }
    }
    
    private func handleLoginState(_ state: BKSession.QRCodeLoginHelper.LoginState) {
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
            case .expired: self.login(anyways: true)
            case .errored:
                let yes = WKAlertAction(title: "OK", style: .default)
                { [weak self] in self?.login(anyways: true) }
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
        isLoginInProcess = false
        WKExtension.shared().isAutorotating = false
        if #available(watchOS 7.0, *) {
            // user configurable
        } else {
            WKExtension.shared().isFrontmostTimeoutExtended = false
        }
        presentNormalInterface()
    }
    
    override func willActivate() {
        super.willActivate()
        if BKSession.shared.isLoggedIn { return loggedIn() }
        WKExtension.shared().isAutorotating = true
        if #available(watchOS 7.0, *) {
            // user configurable
        } else {
            WKExtension.shared().isFrontmostTimeoutExtended = true
        }
        login()
    }
}
