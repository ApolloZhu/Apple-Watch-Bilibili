//
//  BKLogin.swift
//  bilibili
//
//  Created by Apollo Zhu on 9/30/17.
//  Copyright © 2017 Apollo Zhu. All rights reserved.
//

import Foundation
import swift_qrcodejs

#if os(iOS) || os(tvOS) || watchOS
    import UIKit
#endif

public struct BKLogin {
    private static var _cookie: BKCookie?
    static var cookie: BKCookie? {
        get {
            return _cookie
        }
        set {
            _cookie = newValue
        }
    }
    
    // Just to make sure no one ever gets a
    private init() { }
    
    public static func logout() {
        BKLogin.cookie = nil
    }
    
    public static func login(withCookie cookie: BKCookie) {
        BKLogin.cookie = cookie
    }
    
    private static var timer: Timer? {
        willSet {
            timer?.invalidate()
        }
    }
    
    public static func login(handleLoginInfo: @escaping (LoginURL) -> Void, handleLoginState: @escaping (LoginState) -> Void) {
        fetchLoginURL { result in
            switch result {
            case .success(let url):
                handleLoginInfo(url)
                
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                    func heartbeat() {
                        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: DispatchTime.now() + 3) {
                            timer.fire()
                        }
                    }
                    fetchLoginInfo(oauthKey: url.oauthKey) { result in
                        switch result {
                        case .success(let state):
                            switch state {
                            case .succeeded(cookie: let cookie):
                                BKLogin.timer = nil
                                login(withCookie: cookie)
                            case .expired:
                                BKLogin.timer = nil
                            default:
                                heartbeat()
                            }
                            handleLoginState(state)
                        case .errored(response: let response, error: let error):
                            print("""
                                Response: \(response?.description ?? "No Response")
                                Error: \(error?.localizedDescription ?? "No Error")
                                """)
                            heartbeat()
                        }
                    }
                }
                timer?.fire()
            case .errored(response: let response, error: let error):
                fatalError("""
                    Response: \(response?.description ?? "No Response")
                    Error: \(error?.localizedDescription ?? "No Error")
                    """)
            }
        }
    }
    
    private enum BKFetchResult<E> {
        case success(E)
        case errored(response: URLResponse?, error: Swift.Error?)
    }
    
    private typealias BKFetchResultHandler<E> = (_ result: BKFetchResult<E>) -> Void
    
    // MARK: Login URL Fetching
    
    /// Only valid for 3 minutes
    public struct LoginURL: Codable {
        let url: String
        let oauthKey: String
        
        struct Wrapper: Codable {
            let data: LoginURL
        }
        
        /*
         func qrCode(inputCorrectionLevel: QRErrorCorrectLevel) -> UIImage? {
         let data = url.data(using: .utf8)
         guard let filter = CIFilter(name: "CIQRCodeGenerator")
         else { return nil }
         filter.setValue(data, forKey: "inputMessage")
         filter.setValue(inputCorrectionLevel.ciQRCodeGeneratorInputCorrectionLevel,
         forKey: "inputCorrectionLevel")
         guard let ciimage = filter.outputImage else { return nil }
         return UIImage(ciImage: ciimage)
         }
         */
    }
    
    private static func fetchLoginURL(handler: @escaping BKFetchResultHandler<LoginURL>) {
        let url = URL(string: "https://passport.bilibili.com/qrcode/getLoginUrl")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                let wrapper = try? JSONDecoder().decode(LoginURL.Wrapper.self, from: data)
                else { return handler(.errored(response: response, error: error)) }
            return handler(.success(wrapper.data))
        }
        task.resume()
    }
    
    // MARK: Login Info Fetching
    
    fileprivate struct LoginInfo: Codable {
        /// If has login info.
        /// Set-Cookie if true.
        let status: Bool
        /// Login process status.
        /// -4: not scaned.
        /// -5: not confirmed.
        /// -2: expired.
        /// -1: no auth key present.
        let data: Int
        /// Login process status explaination.
        let message: String
    }
    
    public enum LoginState {
        case started
        case needsConfirmation
        case succeeded(cookie: BKCookie)
        case expired
        case missingOAuthKey
        case unknown(status: Int)
        fileprivate static func of(_ info: LoginInfo) -> LoginState {
            switch info.data {
            case -1: return .missingOAuthKey
            case -2: return .expired
            case -4: return .started
            case -5: return .needsConfirmation
            default: return .unknown(status: info.data)
            }
        }
    }
    
    
    /// <#Description#>
    /// Needs to be constantly checked.
    ///
    /// - Parameters:
    ///   - oauthKey: <#oauthKey description#>
    ///   - handler: <#handler description#>
    private static func fetchLoginInfo(oauthKey: String, handler: @escaping BKFetchResultHandler<LoginState>) {
        let url = URL(string: "https://passport.bilibili.com/qrcode/getLoginInfo")!
        var request = postRequest(to: url)
        /// Content-Type: application/x-www-form-urlencoded
        request.httpBody = "oauthKey=\(oauthKey)".data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                if let headerFields = response.allHeaderFields as? [String: String],
                    let cookies = headerFields["Set-Cookie"] {
                    guard let cookie = BKCookie(cookies: cookies) else { fatalError("Logic Error") }
                    return handler(.success(.succeeded(cookie: cookie)))
                }
            } else if let data = data,
                let info = try? JSONDecoder().decode(LoginInfo.self, from: data) {
                return handler(.success(LoginState.of(info)))
            } else {
                return handler(.errored(response: response, error: error))
            }
        }
        task.resume()
    }
    
    
    private static func postRequest(to url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("io.github.apollozhu.bilibili", forHTTPHeaderField: "User-Agent")
        if let cookieHeader = cookie?.valueForHeaderFieldCookie {
            request.addValue(cookieHeader, forHTTPHeaderField: "Cookie")
        }
        return request
    }
    
}
