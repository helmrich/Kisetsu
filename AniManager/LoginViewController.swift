//
//  LoginViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 18.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class LoginViewController: AniManagerViewController {

    // MARK: - Properties
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var emailTextField: AniManagerTextField!
    @IBOutlet weak var passwordTextField: AniManagerTextField!
    @IBOutlet weak var loginButton: AniManagerButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var skipLoginButton: UIButton!
    
    // MARK: - Actions
    
    @IBAction func openSignUpPage() {
        if let url = URL(string: Constant.aniListSignUpString) {
            presentWebViewController(with: url)
        } else {
            showError(withMessage: "Couldn't open Sign-Up page. Try again.")
        }
    }
    
    @IBAction func openForgotPasswordPage() {
        if let url = URL(string: Constant.aniListForgotPasswordUrlString) {
            presentWebViewController(with: url)
        } else {
            showError(withMessage: "Couldn't open Forgot Password page. Try again.")
        }
    }
    
    @IBAction func skipLogin() {
        // TODO: Implement
    }
    
    @IBAction func login() {
        loginButton.setActivityIndicator(active: true)
    }
    
    
    // MARK: - Functions
    
    func presentWebViewController(with url: URL) {
        let webViewController = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.url = url
        present(webViewController, animated: true, completion: nil)
    }

}
