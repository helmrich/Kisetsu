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
        let cell = tableView.dequeueReusableCell(withIdentifier: "genreCell") as! FavoriteGenreTableViewCell
        cell.textLabel?.font = UIFont(name: Constant.FontName.mainBold, size: 20.0)
        cell.textLabel?.textColor = .aniManagerBlack
        cell.textLabel?.text = DataSource.shared.genres[indexPath.row]
        
        
        if let favoriteGenres = UserDefaults.standard.object(forKey: "favoriteGenres") as? [String],
        let textLabel = cell.textLabel,
        let text = textLabel.text {
            if favoriteGenres.contains(text) {
                cell.isSelected = true
            } else {
                cell.isSelected = false
            }
        }
        
        return cell
    }
}


// MARK: - Table View Delegate

extension FavoriteGenresTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected Row...")
        if UserDefaults.standard.object(forKey: "favoriteGenres") == nil {
            UserDefaults.standard.set([String](), forKey: "favoriteGenres")
        }
        
        guard let selectedCell = tableView.cellForRow(at: indexPath),
            let textLabel = selectedCell.textLabel,
            let text = textLabel.text else {
                return
        }
        
        var selectedGenres: [String]
        if let favoriteGenres = UserDefaults.standard.object(forKey: "favoriteGenres") as? [String] {
            selectedGenres = favoriteGenres
            selectedGenres.append(text)
        } else {
            selectedGenres = [text]
        }
        
        UserDefaults.standard.set(selectedGenres, forKey: "favoriteGenres")
        print(UserDefaults.standard.object(forKey: "favoriteGenres"))
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("Deselected Row...")
        guard let favoriteGenres = UserDefaults.standard.object(forKey: "favoriteGenres") as? [String] else {
            return
        }
        
        guard let deselectedCell = tableView.cellForRow(at: indexPath),
            let textLabel = deselectedCell.textLabel,
            let text = textLabel.text else {
                return
        }
        
        let updatedFavoriteGenres = favoriteGenres.filter { $0 != text }
        
        UserDefaults.standard.set(updatedFavoriteGenres, forKey: "favoriteGenres")
        print(UserDefaults.standard.object(forKey: "favoriteGenres"))
    }
}














