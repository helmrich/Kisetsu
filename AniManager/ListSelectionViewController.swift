//
//  ListSelectionViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 11.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

/*
    The ListSelectionViewController is the AnimeList/MangaListSelectionViewController's
    superclass. It contains most of the selection view controller's logic as it
    implements the table view data source and delegate methods. The selection view
    controllers display all available lists for a series type and when selected they
    present a list detail view controller with the list's content
 */

class ListSelectionViewController: UIViewController {
    
    // MARK: - Properties
    
    var seriesType: SeriesType? = .anime

    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NetworkActivityManager.shared.numberOfActiveConnections = 0
    }
}


// MARK: - Table View Data Source

extension ListSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Make sure the view controller's series type is not nil
        guard let seriesType = seriesType else {
            return 0
        }
        
        /*
            If the series type is anime the number of all
            anime list names should be returned, otherwise
            the number of all manga list names should be
            returned
         */
        guard seriesType == .anime else {
            return MangaListName.allNames.count
        }
        
        return AnimeListName.allNames.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listNameTableViewCell") as! ListNameTableViewCell
        
        // Make sure the view controller's series type is not nil
        guard let seriesType = seriesType else {
            return UITableViewCell(frame: CGRect.zero)
        }
        
        /*
            If the series type is anime get the list name at the index of the
            current index path's row from all anime list names, otherwise get
            the name from all manga list names
         */
        guard seriesType == .anime else {
            let currentMangaListName = MangaListName.allNames[indexPath.row]
            cell.listNameLabel.text = currentMangaListName
            return cell
        }
        
        let currentAnimeListName = AnimeListName.allNames[indexPath.row]
        cell.listNameLabel.text = currentAnimeListName
        return cell
        
    }
}


// MARK: - Table View Delegate

extension ListSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! ListNameTableViewCell
        
        // Make sure the view controller's series type is not nil
        guard let seriesType = seriesType else {
            return
        }
        
        guard let listDetailViewController = storyboard?.instantiateViewController(withIdentifier: "listDetailViewController") as? ListDetailViewController else {
            return
        }
        
        /*
            Check the series type, set the list detail view controller's
            properties depending on the series type and push the list
            detail view controller onto the navigation stack
         */
        guard seriesType == .anime else {
            listDetailViewController.title = selectedCell.listNameLabel.text
            listDetailViewController.seriesType = .manga
            navigationController?.pushViewController(listDetailViewController, animated: true)
            return
        }
        
        listDetailViewController.title = selectedCell.listNameLabel.text
        listDetailViewController.seriesType = .anime
        navigationController?.pushViewController(listDetailViewController, animated: true)
    }
    
    /*
        Set the rows' height value to a value that makes all rows combined fill
        out all the available space between the tab bar and the navigation bar
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let fullHeight = tableView.frame.height
        let heightForRow: CGFloat
        if seriesType == .anime {
            heightForRow = fullHeight / CGFloat(AnimeListName.allNames.count)
        } else {
            heightForRow = fullHeight / CGFloat(MangaListName.allNames.count)
        }
        return heightForRow
    }
}
