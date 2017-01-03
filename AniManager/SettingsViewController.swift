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
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        settingsTableView.reloadData()
    }
    
    
    // MARK: - Functions
    
    func explicitContentSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "showExplicitContent")
    }
    
    func logout() {
        /*
            Reset all values in the user defaults that are related to the
            access token and the AniList client's authorization code
            property to nil and present the authentication view controller
         */
        UserDefaults.standard.set(nil, forKey: "accessToken")
        UserDefaults.standard.set(nil, forKey: "expirationTimestamp")
        UserDefaults.standard.set(nil, forKey: "tokenType")
        UserDefaults.standard.set(nil, forKey: "refreshToken")
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
        cell?.textLabel?.textColor = .aniManagerBlack
        cell?.detailTextLabel?.textColor = .aniManagerBlack
        cell?.detailTextLabel?.isHidden = true
        for (_, settingValues) in DataSource.shared.settings[indexPath.section] {
            
            let currentSettingName = settingValues[indexPath.row]
            
            if currentSettingName.uppercased() == "SHOW EXPLICIT CONTENT" {
                cell = tableView.dequeueReusableCell(withIdentifier: "settingSwitchCell")
                (cell as! SettingSwitchTableViewCell).settingTextLabel.text = currentSettingName
                (cell as! SettingSwitchTableViewCell).settingSwitch.isOn = UserDefaults.standard.bool(forKey: "showExplicitContent")
                (cell as! SettingSwitchTableViewCell).settingSwitch.addTarget(self, action: #selector(explicitContentSwitchChanged), for: .valueChanged)
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
            }
        }
    }
}
