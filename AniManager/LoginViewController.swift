//
//  LoginViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 18.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - Properties
    
    var errorMessageView = ErrorMessageView()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    @IBOutlet weak var loginButton: AniManagerButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var skipLoginButton: UIButton!
    
    // MARK: - Actions
    @IBAction func openSignUpPage() {
        if let url = URL(string: Constant.URL.aniListSignUpString) {
            presentWebViewController(with: url)
        } else {
            errorMessageView.showError(withMessage: "Couldn't open Sign-Up page. Try again.")
        }
    }
    
    @IBAction func openForgotPasswordPage() {
        if let url = URL(string: Constant.URL.aniListForgotPasswordUrlString) {
            presentWebViewController(with: url)
        } else {
            errorMessageView.showError(withMessage: "Couldn't open Forgot Password page. Try again.")
        }
    }
    
    @IBAction func skipLogin() {
        // TODO: Implement
    }
    
    @IBAction func login() {
        // Create an AniList URL for requesting an authorization code and
        // present the web view controller with this URL
        let parameters: [String:Any] = [
            AniListConstant.ParameterKey.Authentication.grantType: AniListConstant.ParameterValue.Authentication.grantTypeAuthorizationCode,
            AniListConstant.ParameterKey.Authentication.clientId: AniListConstant.Account.clientId,
            AniListConstant.ParameterKey.Authentication.redirectUri: AniListConstant.ParameterValue.Authentication.redirectUri,
            AniListConstant.ParameterKey.Authentication.responseType: AniListConstant.ParameterValue.Authentication.responseTypeCode
        ]
        if let url = AniListClient.createAniListUrl(withPath: AniListConstant.Path.Authentication.authorize, andParameters: parameters) {
            presentWebViewController(with: url)
        }
    }
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add the error message view to the login view controller as a subview and
        // set its constraints
        view.addSubview(errorMessageView)
        errorMessageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                NSLayoutConstraint(item: errorMessageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60),
                NSLayoutConstraint(item: errorMessageView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: errorMessageView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: errorMessageView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
            ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = AniListClient.shared.authorizationCode {
            
            AniListClient.shared.getAccessToken(withAuthorizationCode: true, completionHandlerForTokens: { (accessToken, refreshToken, errorMessage) in
                
                guard errorMessage == nil else {
                    DispatchQueue.main.async {
                        self.errorMessageView.showError(withMessage: errorMessage!)
                    }
                    return
                }
                
                guard let accessToken = accessToken else {
                    DispatchQueue.main.async {
                        self.errorMessageView.showError(withMessage: "Couldn't get access token")
                    }
                    return
                }
                
                guard let refreshToken = refreshToken else {
                    DispatchQueue.main.async {
                        self.errorMessageView.showError(withMessage: "Couldn't get refresh token")
                    }
                    return
                }
                
                UserDefaults.standard.set(accessToken.accessTokenValue, forKey: "accessToken")
                UserDefaults.standard.set(accessToken.expirationTimestamp, forKey: "expirationTimestamp")
                UserDefaults.standard.set(accessToken.tokenType, forKey: "tokenType")
                UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
                
            })
        } else {
            print("No authorization code available")
        }
    }
    
    
    // MARK: - Functions
    
    func presentWebViewController(with url: URL) {
        let webViewController = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.url = url
        present(webViewController, animated: true, completion: nil)
    }

}
