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
    }
}


// MARK: - Table View Data Source

extension FavoriteGenresTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataSource.shared.genres.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "genreCell", for: indexPath) as! FavoriteGenreTableViewCell
        cell.textLabel?.font = UIFont(name: Constant.FontName.mainBold, size: 20.0)
        cell.textLabel?.textColor = .aniManagerBlack
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
        guard let selectedCell = tableView.cellForRow(at: indexPath) as? FavoriteGenreTableViewCell,
            let textLabel = selectedCell.textLabel,
            let text = textLabel.text else {
                return
        }
        
        var selectedGenres: [String]
        
        /*
            If the object for the "favoriteGenres" key in the user defaults
            is nil, set an empty string array as the value for this key
         */
        if UserDefaults.standard.object(forKey: "favoriteGenres") == nil {
            UserDefaults.standard.set([String](), forKey: "favoriteGenres")
        }
        
        /*
            Get the favorite genres object from the user defaults and cast
            it to an array of strings. Then append the selected cell's text
            to the array and overwrite the user defaults' object with the
            "favoriteGenres" key with this array
         */
        selectedGenres = UserDefaults.standard.object(forKey: "favoriteGenres") as! [String]
        selectedGenres.append(text)
        
        UserDefaults.standard.set(selectedGenres, forKey: "favoriteGenres")
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let favoriteGenres = UserDefaults.standard.object(forKey: "favoriteGenres") as? [String] else {
            return
        }
        
        guard let deselectedCell = tableView.cellForRow(at: indexPath) as? FavoriteGenreTableViewCell,
            let textLabel = deselectedCell.textLabel,
            let text = textLabel.text else {
                return
        }
        
        let updatedFavoriteGenres = favoriteGenres.filter { $0 != text }
        
        UserDefaults.standard.set(updatedFavoriteGenres, forKey: "favoriteGenres")
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /*
            Check if favorite genres are stored in the user defaults
            and unwrap the displayed cell's text label and its text.
         
            Then check if the array of favorite genres contains the
            displayed cell's text value and if it does, select the
            table view's row at the cell's index path
         */
        if let favoriteGenres = UserDefaults.standard.object(forKey: "favoriteGenres") as? [String],
            let textLabel = cell.textLabel,
            let text = textLabel.text {
            if favoriteGenres.contains(text) {
                if let _ = cell as? FavoriteGenreTableViewCell {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            }
        }
    }
}

