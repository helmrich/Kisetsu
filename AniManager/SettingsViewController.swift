//
//  SettingsViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 01.01.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import UIKit
import Kingfisher

class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    
    let errorMessageView = ErrorMessageView()
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorMessageView.addToBottom(of: view, withOffsetToBottom: tabBarController != nil ? tabBarController!.tabBar.frame.height : 49.0)
        
        navigationController?.navigationBar.barStyle = .black
        setupInterfaceForCurrentTheme()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupInterfaceForCurrentTheme), name: .themeSettingChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        settingsTableView.reloadData()
    }
    
    
    // MARK: - Functions
    
    func setupInterfaceForCurrentTheme() {
        navigationController?.navigationBar.barTintColor = Style.Color.BarTint.navigationBar
        view.backgroundColor = Style.Color.Background.mainView
        settingsTableView.backgroundColor = Style.Color.Background.settingsTableView
        settingsTableView.separatorStyle = Style.activeTheme == .light ? .singleLine : .none
        settingsTableView.reloadData()
    }
    
    func explicitContentSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: UserDefaultsKey.showExplicitContent.rawValue)
    }
    
    func tagsWithSpoilersSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: UserDefaultsKey.showTagsWithSpoilers.rawValue)
    }
    
    func darkThemeSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set(Style.Theme.dark.rawValue, forKey: UserDefaultsKey.theme.rawValue)
            NotificationCenter.default.post(name: .themeSettingChanged, object: self)
            setupInterfaceForCurrentTheme()
        } else {
            UserDefaults.standard.set(Style.Theme.light.rawValue, forKey: UserDefaultsKey.theme.rawValue)
            NotificationCenter.default.post(name: .themeSettingChanged, object: self)
            setupInterfaceForCurrentTheme()
        }
    }
    
    func logout() {
        /*
            Reset all values in the user defaults that are related to the
            access token and the AniList client's authorization code
            property to nil and present the authentication view controller
         */
        UserDefaults.standard.set(nil, forKey: UserDefaultsKey.accessToken.rawValue)
        UserDefaults.standard.set(nil, forKey: UserDefaultsKey.expirationTimestamp.rawValue)
        UserDefaults.standard.set(nil, forKey: UserDefaultsKey.tokenType.rawValue)
        UserDefaults.standard.set(nil, forKey: UserDefaultsKey.refreshToken.rawValue)
        UserDefaults.standard.set(nil, forKey: UserDefaultsKey.grantType.rawValue)
        AniListClient.shared.authorizationCode = nil
        
        let authenticationViewController = storyboard!.instantiateViewController(withIdentifier: "authenticationViewController")
        present(authenticationViewController, animated: true, completion: nil)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return DataSource.shared.settings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfSettingValues = 0
        for (_, settingValues) in DataSource.shared.settings[section] {
            numberOfSettingValues = settingValues.count
        }
        return numberOfSettingValues
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var settingsCategoryName = ""
        for (settingsCategory, _) in DataSource.shared.settings[section] {
            settingsCategoryName = settingsCategory
        }
        return settingsCategoryName
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "settingCell")
        cell?.textLabel?.font = UIFont(name: Constant.FontName.mainRegular, size: 18.0)
        cell?.detailTextLabel?.font = UIFont(name: Constant.FontName.mainLight, size: 18.0)
        cell?.textLabel?.textColor = Style.Color.Text.tableViewCell
        cell?.detailTextLabel?.textColor = Style.Color.Text.tableViewCell
        cell?.backgroundColor = Style.Color.Background.tableViewCell
        cell?.detailTextLabel?.isHidden = true
        for (_, settingValues) in DataSource.shared.settings[indexPath.section] {
            
            let currentSettingName = settingValues[indexPath.row]
            
            if currentSettingName.uppercased() == "SHOW EXPLICIT CONTENT" {
                cell = tableView.dequeueReusableCell(withIdentifier: "settingSwitchCell")
                (cell as! SettingSwitchTableViewCell).settingTextLabel.text = currentSettingName
                (cell as! SettingSwitchTableViewCell).settingSwitch.isOn = UserDefaults.standard.bool(forKey: "showExplicitContent")
                (cell as! SettingSwitchTableViewCell).settingSwitch.addTarget(self, action: #selector(explicitContentSwitchChanged), for: .valueChanged)
                return (cell as! SettingSwitchTableViewCell)
            } else if currentSettingName.uppercased() == "SHOW TAGS WITH SPOILERS" {
                cell = tableView.dequeueReusableCell(withIdentifier: "settingSwitchCell")
                (cell as! SettingSwitchTableViewCell).settingTextLabel.text = currentSettingName
                (cell as! SettingSwitchTableViewCell).settingSwitch.isOn = UserDefaults.standard.bool(forKey: "showTagsWithSpoilers")
                (cell as! SettingSwitchTableViewCell).settingSwitch.addTarget(self, action: #selector(tagsWithSpoilersSwitchChanged), for: .valueChanged)
                return (cell as! SettingSwitchTableViewCell)
            } else if currentSettingName.uppercased() == "DARK THEME" {
                cell = tableView.dequeueReusableCell(withIdentifier: "settingSwitchCell")
                (cell as! SettingSwitchTableViewCell).settingTextLabel.text = currentSettingName
                (cell as! SettingSwitchTableViewCell).settingSwitch.isOn = Style.activeTheme == .dark
                (cell as! SettingSwitchTableViewCell).settingSwitch.addTarget(self, action: #selector(darkThemeSwitchChanged), for: .valueChanged)
                return (cell as! SettingSwitchTableViewCell)
            } else if currentSettingName.uppercased() == "CLEAR DISK IMAGE CACHE" {
                ImageCache.default.calculateDiskCacheSize { sizeInBytes in
                    // Set the cell's detail text label to the cache's size in mb
                    cell?.detailTextLabel?.text = "\(sizeInBytes / 1000 / 1000)mb"
                    cell?.detailTextLabel?.textColor = .aniManagerRed
                    cell?.detailTextLabel?.isHidden = false
                }
            }
            
            cell?.textLabel?.text = currentSettingName
            
            if currentSettingName.uppercased() == "LOGOUT" {
                cell?.textLabel?.textColor = .aniManagerRed
            }
        }
        return cell!
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        for (_, settingValues) in DataSource.shared.settings[indexPath.section] {
            let currentSettingName = settingValues[indexPath.row]
            
            if currentSettingName.uppercased() == "CLEAR DISK IMAGE CACHE" {
                ImageCache.default.clearDiskCache {
                    tableView.reloadRows(at: [indexPath], with: .fade)
                }
            } else if currentSettingName.uppercased() == "SEND FEEDBACK" {
                UIApplication.shared.open(URL(string: "mailto:me@tobias-helmrich.de")!, options: [:], completionHandler: nil)
            } else if currentSettingName.uppercased() == "LOGOUT" {
                logout()
            } else if currentSettingName.uppercased() == "FAVORITE GENRES" {
                let favoriteGenresTableViewController = storyboard?.instantiateViewController(withIdentifier: "favoriteGenresTableViewController") as! FavoriteGenresTableViewController
                navigationController?.pushViewController(favoriteGenresTableViewController, animated: true)
            } else if currentSettingName.uppercased() == "PREFERRED TITLE LANGUAGE" {
                let preferredLanguageTableViewController = storyboard?.instantiateViewController(withIdentifier: "preferredLanguageTableViewController") as! PreferredLanguageTableViewController
                navigationController?.pushViewController(preferredLanguageTableViewController, animated: true)
            } else if currentSettingName.uppercased() == "FORUM" {
                if let forumURL = URL(string: Constant.URL.aniListForumRecentURLString) {
                    presentWebViewController(with: forumURL)
                } else {
                    errorMessageView.showAndHide(withMessage: "Couldn't open forum")
                }
            } else if currentSettingName.uppercased() == "USER PROFILE" {
                AniListClient.shared.getAuthenticatedUser { (user, errorMessage) in
                    guard errorMessage == nil else {
                        self.errorMessageView.showAndHide(withMessage: errorMessage!)
                        return
                    }
                    
                    guard let user = user else {
                        self.errorMessageView.showAndHide(withMessage: "Can't show user profile")
                        return
                    }
                    
                    if let userProfileURL = URL(string: "https://anilist.co/user/\(user.id)") {
                        print(userProfileURL)
                        self.presentWebViewController(with: userProfileURL)
                    } else {
                        self.errorMessageView.showAndHide(withMessage: "Can't open user profile")
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as? UITableViewHeaderFooterView)?.textLabel?.textColor = Style.Color.Text.tableViewSectionHeaderTitle
    }
}
