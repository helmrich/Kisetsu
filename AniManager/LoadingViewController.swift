//
//  LoadingViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 23.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

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
        
        getAccessToken()
    }
    
    
    // MARK: - Functions
    
    func getAccessToken() {
        
        toggleStatus(loading: true)
        
        AniListClient.shared.getAccessToken(withRefreshToken: true) { accessToken, _, errorMessage in
            guard errorMessage == nil else {
                self.errorMessageView.showError(withMessage: errorMessage!)
                self.toggleStatus(loading: false)
                return
            }
            
            guard let accessToken = accessToken else {
                self.errorMessageView.showError(withMessage: "Couldn't get access token. Try again.")
                self.toggleStatus(loading: false)
                return
            }
            
            UserDefaults.standard.set(accessToken.accessTokenValue, forKey: "accessToken")
            UserDefaults.standard.set(accessToken.expirationTimestamp, forKey: "expirationTimestamp")
            
            DispatchQueue.main.async {
                let navigationController = self.storyboard?.instantiateViewController(withIdentifier: "navigationController") as! NavigationController
                self.present(navigationController, animated: true, completion: nil)
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
