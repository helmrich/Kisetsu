//
//  AppDelegate.swift
//  AniManager
//
//  Created by Tobias Helmrich on 18.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        /*
            Configure the application-wide appearance of text fields that are
            contained in a search bar
         */
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = .aniManagerBlack
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = UIFont(name: Constant.FontName.mainRegular, size: 14.0)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        /*
            If no access token is available in the user defaults, the
            authentication view controller should be used as the root
            view controller as the user didn't authenticate the app
            before
        */
        guard let _ = UserDefaults.standard.string(forKey: "accessToken") else {
            let authenticationViewController = storyboard.instantiateViewController(withIdentifier: "authenticationViewController") as! AuthenticationViewController
            window?.rootViewController = authenticationViewController
            window?.makeKeyAndVisible()
            return true
        }
        
        /*
            If an access token is available, its expiration timestamp should be checked.
            If it expired, the loading view controller should be used as the root view
            controller where a new access token will be requested using a refresh token
         */
        let expirationTimestamp = UserDefaults.standard.integer(forKey: "expirationTimestamp")
        
        guard expirationTimestamp > Int(Date().timeIntervalSince1970) else {
            let loadingViewController = storyboard.instantiateViewController(withIdentifier: "loadingViewController") as! LoadingViewController
            window?.rootViewController = loadingViewController
            window?.makeKeyAndVisible()
            return true
        }

        /*
            If the access token didn't expire yet, the tab bar controller with
            the "main" content of the application should be used as the root
            view controller
         */
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }
}

