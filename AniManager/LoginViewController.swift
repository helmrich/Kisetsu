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
    
    var isKeyboardActive = false
    var errorMessageView = ErrorMessageView()
    
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
            errorMessageView.showError(withMessage: "Couldn't open Sign-Up page. Try again.")
        }
    }
    
    @IBAction func openForgotPasswordPage() {
        if let url = URL(string: Constant.aniListForgotPasswordUrlString) {
            presentWebViewController(with: url)
        } else {
            errorMessageView.showError(withMessage: "Couldn't open Forgot Password page. Try again.")
        }
    }
    
    @IBAction func skipLogin() {
        // TODO: Implement
    }
    
    @IBAction func login() {
        loginButton.setActivityIndicator(active: true)
        view.endEditing(true)
    }
    
    @IBAction func checkTextFieldContent() {
        guard let emailText = emailTextField.text,
            let passwordText = passwordTextField.text else {
            return
        }
        
        if emailText.isEmpty || passwordText.isEmpty {
            loginButton.set(enabled: false)
        } else {
            loginButton.set(enabled: true)
        }
    }
    
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add a tap gesture recognizer to the view controller's main view
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewWasTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // The login button should be disabled initially
        loginButton.set(enabled: false)
        
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
        
        // Add observers for keyboard changes
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: nil, using: keyboardWillShow)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil, using: keyboardWillHide)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove observers for keyboard changes
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    // MARK: - Functions
    
    func presentWebViewController(with url: URL) {
        let webViewController = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.url = url
        present(webViewController, animated: true, completion: nil)
    }
    
    // When the main view is tapped every text field should resign its
    // first responder status so that the keyboard hides if it's currently
    // displayed
    func viewWasTapped() {
        view.endEditing(true)
    }

}


// MARK: - Keyboard Functions

extension LoginViewController {
    func keyboardWillShow(notification: Notification) {
        print("Keyboard will show...")
        guard !isKeyboardActive else {
            return
        }
        
        if let userInfo = notification.userInfo,
            let keyboardFrameEnd = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            // When the keyboard will be shown the main view should be pushed up slightly
            // so the most important elements are visible when typing (other text field,
            // login button, forgot password/sign-up page buttons)
            view.frame.origin.y -= keyboardFrameEnd.height / 1.25
            isKeyboardActive = true
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        print("Keyboard will hide...")
        view.frame.origin.y = 0
        isKeyboardActive = false
    }
}


// MARK: - Text Field Delegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
