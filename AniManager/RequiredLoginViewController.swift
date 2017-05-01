//
//  RequiredLoginViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 30.04.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import Foundation
import UIKit

class RequiredLoginViewController: UIViewController {
    
    var reason: String = ""

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        let informationView = UIView(frame: view.frame)
        informationView.backgroundColor = .aniManagerBlack
        
        let informationMessageLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width * 0.9, height: 200.0))
        informationMessageLabel.numberOfLines = 0
        informationMessageLabel.textColor = .white
        informationMessageLabel.textAlignment = .center
        informationMessageLabel.text = "To \(reason) you have to login with an AniList account"
        informationMessageLabel.center.x = view.center.x
        informationMessageLabel.center.y = view.center.y - 40.0
        informationView.addSubview(informationMessageLabel)
        
        let cancelButton = UIButton(frame: CGRect(x: view.frame.maxX - 45.0, y: 25.0, width: 25.0, height: 25.0))
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.setImage(#imageLiteral(resourceName: "CancelCross"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        informationView.addSubview(cancelButton)
        
        let loginButton = AniManagerButton(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width / 1.25, height: 60.0))
        loginButton.backgroundColor = .white
        loginButton.setTitleColor(.aniManagerBlack, for: .normal)
        loginButton.center.x = view.center.x
        loginButton.center.y = view.center.y + 40.0
        loginButton.setTitle("Login", for: .normal)
        loginButton.addTarget(self, action: #selector(displayAuthenticationViewController), for: .touchUpInside)
        informationView.addSubview(loginButton)
        
        view.addSubview(informationView)
    }
    
    func displayAuthenticationViewController() {
        let authenticationViewController = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "authenticationViewController") as! AuthenticationViewController)
        present(authenticationViewController, animated: true, completion: nil)
    }
    
    func cancel() {
        /*
            If the presenting view controller is a tab bar controller
            the tab bar controller's controller at the 0 index (home/browse)
            should be selected to ensure a view controller that's also
            available to users who are not logged in is displayed when the
            required login view controller is dismissed
         */
        if let tabBarController = presentingViewController as? UITabBarController {
            tabBarController.selectedIndex = 0
        }
        dismiss(animated: true, completion: nil)
    }
}
