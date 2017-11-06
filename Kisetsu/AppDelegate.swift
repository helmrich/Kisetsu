//
//  AppDelegate.swift
//  AniManager
//
//  Created by Tobias Helmrich on 18.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    lazy var coreDataStack = CoreDataStack(modelName: "AniManager")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        registerForPushNotifications()
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
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
        /*
             Check if the presented view controller's class name
             indicates that it's a video player view controller
             and if so, allow all interface orientations except
             upside down. If not, only the portrait orientation
             should be supported
         */
        if let presentedViewController = window?.rootViewController?.presentedViewController {
            let className = String(describing: type(of: presentedViewController))
            if ["MPInlineVideoFullscreenViewController", "MPMoviePlayerViewController", "AVFullScreenViewController"].contains(className)
            {
                return UIInterfaceOrientationMask.allButUpsideDown
            }
        }
        return UIInterfaceOrientationMask.portrait
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print(">_<>_<>_<>_<>_<>_<>_<>_<>_<>_<>_<>_< Performing fetch... >_<>_<>_<>_<>_<>_<>_<>_<>_<>_<>_<>_<")
        
        // TEST
        
        // Display a notification each time a background fetch is performed

        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { notificationRequests in
            
            notificationRequests.forEach({ (notificationRequest) in
                print("\(notificationRequest.identifier), \(notificationRequest.trigger), \(notificationRequest.content)")
            })
            
            let notificationContent = UNMutableNotificationContent()
            notificationContent.title = "Background Fetch was performed"
            notificationContent.sound = .default()
            notificationContent.body = "A background fetch was performed just now! Number of pending notification requests: \(notificationRequests.count)"
            
            let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 2.0, repeats: false)
            
            let notificationRequest = UNNotificationRequest(identifier: "backgroundFetchInformation", content: notificationContent, trigger: notificationTrigger)
            UNUserNotificationCenter.current().add(notificationRequest, withCompletionHandler: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            })
        })
        
        // TEST END
        
        guard let grantTypeString = UserDefaults.standard.string(forKey: UserDefaultsKey.grantType.rawValue),
            let grantType = GrantType(rawValue: grantTypeString) else {
                print("Couldn't get grant type")
                print("><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><")
                print("><><><><><><><><><><><><>< Calling completion handler for background fetch ><><><><><><><><><><><><><")
                print("><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><")
                completionHandler(.noData)
                return
        }
        
        guard grantType != .clientCredentials else {
            print("User is not logged in")
            print("><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><")
            print("><><><><><><><><><><><><>< Calling completion handler for background fetch ><><><><><><><><><><><><><")
            print("><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><")
            completionHandler(.noData)
            return
        }
        
        AniListClient.shared.getAuthenticatedUser { (user, errorMessage) in
            guard errorMessage == nil else {
                print(errorMessage!)
                print("><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><")
                print("><><><><><><><><><><><><>< Calling completion handler for background fetch ><><><><><><><><><><><><><")
                print("><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><")
                completionHandler(.noData)
                return
            }
            
            guard let user = user else {
                print("Couldn't get authenticated user")
                print("><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><")
                print("><><><><><><><><><><><><>< Calling completion handler for background fetch ><><><><><><><><><><><><><")
                print("><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><")
                completionHandler(.noData)
                return
            }
            
            AniListClient.shared.getList(ofType: .anime, withStatus: AnimeListName.watching.asKey(), userId: user.id, andDisplayName: nil) { (currentlyWatchingSeriesList, errorMessage) in
                guard errorMessage == nil else {
                    print(errorMessage!)
                    print("><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><")
                    print("><><><><><><><><><><><><>< Calling completion handler for background fetch ><><><><><><><><><><><><><")
                    print("><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><")
                    completionHandler(.noData)
                    return
                }
                
                guard let currentlyWatchingSeriesList = currentlyWatchingSeriesList as? [AnimeSeries] else {
                    print("Couldn't get \"Currently Watching\" series list")
                    print("><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><")
                    print("><><><><><><><><><><><><>< Calling completion handler for background fetch ><><><><><><><><><><><><><")
                    print("><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><")
                    completionHandler(.noData)
                    return
                }
                
                let currentlyAiringOrNotYetAiredSeries = currentlyWatchingSeriesList.filter({ (animeSeries) -> Bool in
                    animeSeries.airingStatus == .currentlyAiring || animeSeries.airingStatus == .notYetAired
                })
                
                var numberOfCalledSeriesCompletionHandlers = 0
                currentlyAiringOrNotYetAiredSeries.forEach {
                    AniListClient.shared.getSingleSeries(ofType: .anime, withId: $0.id, completionHandlerForSeries: { (seriesPageModel, errorMessage) in
                        numberOfCalledSeriesCompletionHandlers += 1
                        
                        guard errorMessage == nil else {
                            print(errorMessage!)
                            return
                        }
                        
                        guard let seriesPageModel = seriesPageModel as? AnimeSeries else {
                            print("Couldn't get series page model")
                            return
                        }
                        
                        guard let nextEpisodeNumber = seriesPageModel.nextEpisodeNumber,
                            let secondsUntilNextEpisode = seriesPageModel.countdownUntilNextEpisodeInSeconds else {
                                print("Couldn't get next episode number and/or seconds until next episode")
                                return
                        }
                        
                        let notificationContent = UNMutableNotificationContent()
                        notificationContent.title = "New Episode"
                        notificationContent.sound = UNNotificationSound.default()
                        
                        let notificationTrigger: UNTimeIntervalNotificationTrigger
                        let identifier: String
                        
                        if secondsUntilNextEpisode >= 43200 {
                            identifier = "\(seriesPageModel.titleRomaji)-\(seriesPageModel.id)-12h"
                            notificationContent.body = "Episode \(nextEpisodeNumber) of \(seriesPageModel.titleRomaji) will air in 12 hours"
                            
                            notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(secondsUntilNextEpisode) - TimeInterval(43200), repeats: false)
                        } else if secondsUntilNextEpisode >= 32400 {
                            identifier = "\(seriesPageModel.titleRomaji)-\(seriesPageModel.id)-9h"
                            notificationContent.body = "Episode \(nextEpisodeNumber) of \(seriesPageModel.titleRomaji) will air in 9 hours"
                            
                            notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(secondsUntilNextEpisode) - TimeInterval(32400), repeats: false)
                        } else if secondsUntilNextEpisode >= 21600 {
                            identifier = "\(seriesPageModel.titleRomaji)-\(seriesPageModel.id)-6h"
                            notificationContent.body = "Episode \(nextEpisodeNumber) of \(seriesPageModel.titleRomaji) will air in 6 hours"
                            
                            notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(secondsUntilNextEpisode) - TimeInterval(21600), repeats: false)
                        } else if secondsUntilNextEpisode >= 10800 {
                            identifier = "\(seriesPageModel.titleRomaji)-\(seriesPageModel.id)-3h"
                            notificationContent.body = "Episode \(nextEpisodeNumber) of \(seriesPageModel.titleRomaji) will air in 3 hours"
                            
                            notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(secondsUntilNextEpisode) - TimeInterval(10800), repeats: false)
                        } else if secondsUntilNextEpisode >= 3600 {
                            identifier = "\(seriesPageModel.titleRomaji)-\(seriesPageModel.id)-1h"
                            notificationContent.body = "Episode \(nextEpisodeNumber) of \(seriesPageModel.titleRomaji) will air in 1 hour"
                            
                            notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(secondsUntilNextEpisode) - TimeInterval(3600), repeats: false)
                        } else if secondsUntilNextEpisode <= 300 && secondsUntilNextEpisode >= 600 {
                            identifier = "\(seriesPageModel.titleRomaji)-\(seriesPageModel.id)-0h"
                            notificationContent.body = "Episode \(nextEpisodeNumber) of \(seriesPageModel.titleRomaji) is airing now"
                            
                            notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
                        } else {
                            return
                        }
                        
                        let request = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: notificationTrigger)
                        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                            if let error = error {
                                print(error.localizedDescription)
                            }
                            if numberOfCalledSeriesCompletionHandlers >= currentlyAiringOrNotYetAiredSeries.count {
                                print("><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><")
                                print("><><><><><><><><><><><><>< Calling completion handler for background fetch ><><><><><><><><><><><><><")
                                print("><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><")
                                completionHandler(.newData)
                            }
                        })
                        
                        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { notificationRequests in
                            print("><><><><><><><><><><><><><><><")
                            notificationRequests.forEach { notificationRequest in
                                if let trigger = notificationRequest.trigger as? UNTimeIntervalNotificationTrigger {
                                    let hoursUntilNextEpisode = trigger.timeInterval / 3600
                                    print("\(notificationRequest.identifier) in \(hoursUntilNextEpisode) hours")
                                }
                            }
                            print("><><><><><><><><><><><><><><><")
                        })
                        
                    })
                }
                
            }
        }
    }
    
    // MARK: - Notifications
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            print("Notification settings: \(notificationSettings)")
            guard notificationSettings.authorizationStatus == .authorized else { return }
            
            print(notificationSettings.authorizationStatus)
            
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // TODO
        print(response)
    }
}
