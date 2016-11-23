//
//  LoadingViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 23.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    let errorMessageView = ErrorMessageView()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AniListClient.shared.getAccessToken(withRefreshToken: true) { accessToken, _, errorMessage in
            guard errorMessage == nil else {
                self.errorMessageView.showError(withMessage: errorMessage!)
                return
            }
            
            guard let accessToken = accessToken else {
                self.errorMessageView.showError(withMessage: "Couldn't get access token. Try again.")
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

}
