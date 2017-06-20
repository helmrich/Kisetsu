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
    
    override init() {
        super.init()
        UIView.classInit
    }

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    lazy var coreDataStack = CoreDataStack(modelName: "AniManager")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        /*
            Configure the application-wide appearance of text fields that are
            contained in a search bar
         */
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = .aniManagerBlack
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = UIFont(name: Constant.FontName.mainRegular, size: 14.0)
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.isNotFirstStart.rawValue) == false {
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.isNotFirstStart.rawValue)
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.downloadHighQualityImages.rawValue)
        }
        
        /*
            Check if a title language is set in the user defaults and set
            the value to "english" if there is no value
         */
        if UserDefaults.standard.string(forKey: UserDefaultsKey.titleLanguage.rawValue) == nil {
            UserDefaults.standard.set(TitleLanguage.english.rawValue, forKey: UserDefaultsKey.titleLanguage.rawValue)
        }
        
        if UserDefaults.standard.string(forKey: UserDefaultsKey.theme.rawValue) == nil {
            UserDefaults.standard.set(Style.Theme.light.rawValue, forKey: UserDefaultsKey.theme.rawValue)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        /*
            If no access token is available in the user defaults, the
            authentication view controller should be used as the root
            view controller as the user didn't authenticate the app
            before
        */
        guard let _ = UserDefaults.standard.string(forKey: UserDefaultsKey.accessToken.rawValue) else {
            let authenticationViewController = storyboard.instantiateViewController(withIdentifier: "authenticationViewController") as! AuthenticationViewController
            window?.rootViewController = authenticationViewController
            window?.makeKeyAndVisible()
            return true
        }
        
        /*
            If an access token is available, its expiration timestamp should be checked.
            If it expired, the loading view controller should be used as the root view
            controller where a new access token will be requested using a refresh token.
            If the client credentials grant type was used as a grant type before, the
            authentication view controller should be presented, so the user can decide
            between either skip the login once again to authenticate with client credentials
            or logging in
         */
        let expirationTimestamp = UserDefaults.standard.integer(forKey: UserDefaultsKey.expirationTimestamp.rawValue)
        
        guard expirationTimestamp > Int(Date().timeIntervalSince1970) else {
            if let grantTypeString = UserDefaults.standard.string(forKey: UserDefaultsKey.grantType.rawValue),
                let grantType = GrantType(rawValue: grantTypeString),
                grantType == .authorizationCode || grantType == .refreshToken {
                let loadingViewController = storyboard.instantiateViewController(withIdentifier: "loadingViewController") as! LoadingViewController
                window?.rootViewController = loadingViewController
                window?.makeKeyAndVisible()
            } else {
                let authenticationViewController = storyboard.instantiateViewController(withIdentifier: "authenticationViewController") as! AuthenticationViewController
                window?.rootViewController = authenticationViewController
                window?.makeKeyAndVisible()
            }
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
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        coreDataStack.saveContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        coreDataStack.saveContext()
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let presentedViewController = window?.rootViewController?.presentedViewController {
            let className = String(describing: type(of: presentedViewController))
            if ["MPInlineVideoFullscreenViewController", "MPMoviePlayerViewController", "AVFullScreenViewController"].contains(className)
            {
                return UIInterfaceOrientationMask.allButUpsideDown
            }
        }
        return UIInterfaceOrientationMask.portrait
    }
}

