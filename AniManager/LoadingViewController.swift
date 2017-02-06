//
//  LoadingViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 23.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

/*
    The loading view controller will be used when
    the user authenticated the application before but
    the access token is not valid anymore, thus a new
    one has to be requested with a refresh token.
 
    When this view controller is loaded, it immediately
    tries to get a new access token. If it fails, it
    communicates the error and gives the user the option
    to retry requesting a new access token.
 */

class LoadingViewController: UIViewController {
    
    // MARK: - Properties
    
    let errorMessageView = ErrorMessageView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    // MARK: - Outlets and Actions
    
    // MARK: - Outlets

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var tryAgainButton: UIButton!
    
    @IBAction func retry() {
        getAccessToken()
    }
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorMessageView.addToBottom(of: view)
        
        getAccessToken()
    }
    
    
    // MARK: - Functions
    
    func getAccessToken() {
        
        toggleStatus(loading: true)
        
        AniListClient.shared.getAccessToken(withRefreshToken: true) { accessToken, _, errorMessage in
            guard errorMessage == nil else {
                self.errorMessageView.showAndHide(withMessage: errorMessage!)
                self.toggleStatus(loading: false)
                return
            }
            
            guard let accessToken = accessToken else {
                self.errorMessageView.showAndHide(withMessage: "Couldn't get access token. Try again.")
                self.toggleStatus(loading: false)
                return
            }
            
            UserDefaults.standard.set(accessToken.accessTokenValue, forKey: "accessToken")
            UserDefaults.standard.set(accessToken.expirationTimestamp, forKey: "expirationTimestamp")
            
            DispatchQueue.main.async {
                let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
                self.present(tabBarController, animated: true, completion: nil)
            }
            
        }
    }
    
    func toggleStatus(loading: Bool) {
        if !loading {
            DispatchQueue.main.async {
                self.statusLabel.text = "Authentication failed"
                self.tryAgainButton.isHidden = false
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.isHidden = true
            }
        } else {
            DispatchQueue.main.async {
                self.statusLabel.text = "Authenticating ..."
                self.tryAgainButton.isHidden = true
                self.activityIndicatorView.startAnimating()
                self.activityIndicatorView.isHidden = false
            }
        }
    }

}
