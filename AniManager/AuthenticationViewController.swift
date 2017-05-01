//
//  AuthenticationViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 22.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class AuthenticationViewController: UIViewController {
    
    /*
        The authentication view controller will be used
        when the user authenticates the application for
        the first time.
     
        It provides buttons to go to the authentication
        page, the "forgot password" page, or, if the user
        doesn't have an account yet, to the register page.
     */
    
    // MARK: - Properties
    
    var errorMessageView = ErrorMessageView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
            errorMessageView.showAndHide(withMessage: "Couldn't open Sign-Up page. Try again.")
        }
    }
    
    @IBAction func openForgotPasswordPage() {
        if let url = URL(string: Constant.URL.aniListForgotPasswordUrlString) {
            presentWebViewController(with: url)
        } else {
            errorMessageView.showAndHide(withMessage: "Couldn't open Forgot Password page. Try again.")
        }
    }
    
    @IBAction func login() {
        /*
            Create an AniList URL for requesting an authorization code and
            present the web view controller with this URL
         */
        let parameters: [String:Any] = [
            AniListConstant.ParameterKey.Authentication.grantType: AniListConstant.ParameterValue.Authentication.grantTypeAuthorizationCode,
            AniListConstant.ParameterKey.Authentication.clientId: AniListConstant.Account.clientId,
            AniListConstant.ParameterKey.Authentication.redirectUri: AniListConstant.ParameterValue.Authentication.redirectUri,
            AniListConstant.ParameterKey.Authentication.responseType: AniListConstant.ParameterValue.Authentication.responseTypeCode
        ]
        if let url = AniListClient.shared.createAniListUrl(withPath: AniListConstant.Path.Authentication.authorize, andParameters: parameters) {
            presentWebViewController(with: url)
        }
    }
    
    @IBAction func skipLogin() {
        let loadingView = showLoadingStatus()
        AniListClient.shared.getAccessToken(withGrantType: .clientCredentials) { (accessToken, refreshToken, errorMessage) in
            DispatchQueue.main.async {
                self.hideLoadingStatus(of: loadingView)
            }
            guard errorMessage == nil else {
                self.errorMessageView.showAndHide(withMessage: "Couldn't get access token")
                return
            }
            DispatchQueue.main.async {
                let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
                self.present(tabBarController, animated: true, completion: nil)
            }
        }
    }
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
            Add an error message view to the main view and change
            the login button's background color to white
         */
        errorMessageView.addToBottom(of: view)
        loginButton.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /*
            When the main view will appear, check if the AniListClient's
            authorizationCode property is not nil. If that's the case,
            request an access token with the AniListClient's authorization
            code and if an access token is successfully received, set values
            in the user defaults and instantiate and show the "main" tab bar
            controller
         */
        if AniListClient.shared.authorizationCode != nil {
            let loadingView = showLoadingStatus()
            AniListClient.shared.getAccessToken(withGrantType: .authorizationCode) { (accessToken, refreshToken, errorMessage) in
                DispatchQueue.main.async {
                    self.hideLoadingStatus(of: loadingView)
                }
                
                // Error Handling
                guard errorMessage == nil else {
                    self.errorMessageView.showAndHide(withMessage: errorMessage!)
                    return
                }
                
                guard accessToken != nil else {
                    self.errorMessageView.showAndHide(withMessage: "Couldn't get access token")
                    return
                }
                
                guard refreshToken != nil else {
                    self.errorMessageView.showAndHide(withMessage: "Couldn't get refresh token")
                    return
                }
                
                DispatchQueue.main.async {
                    // Instantiate and present tab bar controller
                    let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
                    self.present(tabBarController, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    
    // MARK: - Functions
    
    func presentWebViewController(with url: URL) {
        let webViewController = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.url = url
        present(webViewController, animated: true, completion: nil)
    }
}
