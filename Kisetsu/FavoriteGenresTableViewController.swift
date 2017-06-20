//
//  FavoriteGenresTableViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 02.01.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import UIKit

class FavoriteGenresTableViewController: UIViewController {

    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var genresTableView: UITableView!
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Favorite Genres"
        navigationController?.navigationBar.tintColor = .white
        
        DataSource.shared.getGenres()
        
        setupInterfaceForCurrentTheme()
        
        AniListClient.shared.getGenreList { (genreList, errorMessage) in
            guard errorMessage == nil else {
                return
            }
            
            guard genreList != nil else {
                return
            }
            
            DataSource.shared.getGenres()
            
            DispatchQueue.main.async {
                self.setupInterfaceForCurrentTheme()
            }
        }
    }
    
    
    // MARK: - Functions
    
    func setupInterfaceForCurrentTheme() {
        view.backgroundColor = Style.Color.Background.mainView
        genresTableView.backgroundColor = Style.Color.Background.tableView
        genresTableView.reloadData()
    }
}


// MARK: - Table View Data Source

extension FavoriteGenresTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataSource.shared.genres.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "genreCell", for: indexPath) as! SettingSelectionTableViewCell
        cell.backgroundColor = Style.Color.Background.tableViewCell
        cell.textLabel?.font = UIFont(name: Constant.FontName.mainBold, size: 20.0)
        cell.textLabel?.textColor = Style.Color.Text.tableViewCell
        cell.textLabel?.text = DataSource.shared.genres[indexPath.row]
        return cell
    }
}


// MARK: - Table View Delegate

extension FavoriteGenresTableViewController: UITableViewDelegate {
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
        
        var selectedGenres: [String]
        
        /*
            If the object for the "favoriteGenres" key in the user defaults
            is nil, set an empty string array as the value for this key
         */
        if UserDefaults.standard.object(forKey: UserDefaultsKey.favoriteGenres.rawValue) == nil {
            UserDefaults.standard.set([String](), forKey: UserDefaultsKey.favoriteGenres.rawValue)
        }
        
        /*
            Get the favorite genres object from the user defaults and cast
            it to an array of strings. Then append the selected cell's text
            to the array and overwrite the user defaults' object with the
            "favoriteGenres" key with this array
         */
        selectedGenres = UserDefaults.standard.object(forKey: UserDefaultsKey.favoriteGenres.rawValue) as! [String]
        selectedGenres.append(text)
        
        UserDefaults.standard.set(selectedGenres, forKey: UserDefaultsKey.favoriteGenres.rawValue)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let favoriteGenres = UserDefaults.standard.object(forKey: UserDefaultsKey.favoriteGenres.rawValue) as? [String] else {
            return
        }
        
        guard let deselectedCell = tableView.cellForRow(at: indexPath) as? SettingSelectionTableViewCell,
            let textLabel = deselectedCell.textLabel,
            let text = textLabel.text else {
                return
        }
        
        let updatedFavoriteGenres = favoriteGenres.filter { $0 != text }
        
        UserDefaults.standard.set(updatedFavoriteGenres, forKey: UserDefaultsKey.favoriteGenres.rawValue)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /*
            Check if favorite genres are stored in the user defaults
            and unwrap the displayed cell's text label and its text.
         
            Then check if the array of favorite genres contains the
            displayed cell's text value and if it does, select the
            table view's row at the cell's index path
         */
        if let favoriteGenres = UserDefaults.standard.object(forKey: UserDefaultsKey.favoriteGenres.rawValue) as? [String],
            let textLabel = cell.textLabel,
            let text = textLabel.text {
            if favoriteGenres.contains(text) {
                if let _ = cell as? SettingSelectionTableViewCell {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            }
        }
    }
}

