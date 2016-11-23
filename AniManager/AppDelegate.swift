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
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // If no access token is available in the user defaults, the
        // authentication view controller should be used as the root
        // view controller as the user didn't authenticate the app
        // before
        guard let _ = UserDefaults.standard.string(forKey: "accessToken") else {
            let authenticationViewController = storyboard.instantiateViewController(withIdentifier: "authenticationViewController") as! AuthenticationViewController
            window?.rootViewController = authenticationViewController
            window?.makeKeyAndVisible()
            return true
        }
        
        
        // If an access token is available, its expiration timestamp should be checked.
        // If it expired, the loading view controller should be used as the root view
        // controller where a new access token should be requested with a refresh token
        let expirationTimestamp = UserDefaults.standard.integer(forKey: "expirationTimestamp")
        
        guard expirationTimestamp > Int(Date().timeIntervalSince1970) else {
            let loadingViewController = storyboard.instantiateViewController(withIdentifier: "loadingViewController") as! LoadingViewController
            window?.rootViewController = loadingViewController
            window?.makeKeyAndVisible()
            return true
        }

        // If the access token didn't expire yet, the navigation controller that has
        // the tab bar controller with the "main" content of the application as a root
        // view controller, should be used as the root view controller
        let navigationController = storyboard.instantiateViewController(withIdentifier: "navigationController") as! NavigationController
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }


}

