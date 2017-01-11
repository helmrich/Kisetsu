//
//  PreferredLanguageTableViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 11.01.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import UIKit

class PreferredLanguageTableViewController: UIViewController {
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleLanguagesTableView: UITableView!
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Title Language"
        navigationController?.navigationBar.tintColor = .white
    }
}


// MARK: - Table View Data Source

extension PreferredLanguageTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataSource.shared.titleLanguages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath) as! SettingSelectionTableViewCell
        cell.textLabel?.font = UIFont(name: Constant.FontName.mainBold, size: 20.0)
        cell.textLabel?.textColor = .aniManagerBlack
        cell.textLabel?.text = DataSource.shared.titleLanguages[indexPath.row]
        return cell
    }
}


// MARK: - Table View Delegate

extension PreferredLanguageTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /*
            Check if the selected cell can be received from the table view
            by getting the cell for the row at the selected row's index path
            and unwrap the cell's text label and its text value
         */
        guard let selectedCell = tableView.cellForRow(at: indexPath) as? SettingSelectionTableViewCell,
            let textLabel = selectedCell.textLabel,
            let text = textLabel.text else {
                return
        }
     
        UserDefaults.standard.set(text.lowercased(), forKey: "titleLanguage")
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constant.NotificationKey.settingValueChanged), object: self)
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /*
            Check if favorite genres are stored in the user defaults
            and unwrap the displayed cell's text label and its text.
         
            Then check if the array of favorite genres contains the
            displayed cell's text value and if it does, select the
            table view's row at the cell's index path
         */
        if let titleLanguage = UserDefaults.standard.string(forKey: "titleLanguage"),
            let textLabel = cell.textLabel,
            let text = textLabel.text {
            if titleLanguage == text.lowercased() {
                if let _ = cell as? SettingSelectionTableViewCell {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            }
        }
    }
}
