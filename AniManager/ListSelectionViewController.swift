//
//  ListSelectionViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 11.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class ListSelectionViewController: UIViewController {

    // MARK: - Properties
    
    var seriesType: SeriesType?

}

extension ListSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let seriesType = seriesType else {
            return 0
        }
        
        print(MangaListName.allNames().count)
        
        guard seriesType == .anime else {
            return MangaListName.allNames().count
        }
        
        return AnimeListName.allNames().count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listNameTableViewCell") as! ListNameTableViewCell
        
        guard let seriesType = seriesType else {
            return UITableViewCell(frame: CGRect.zero)
        }
        
        guard seriesType == .anime else {
            let currentMangaListName = MangaListName.allNames()[indexPath.row]
            cell.listNameLabel.text = currentMangaListName
            return cell
        }
        
        let currentAnimeListName = AnimeListName.allNames()[indexPath.row]
        cell.listNameLabel.text = currentAnimeListName
        return cell
        
    }
}

extension ListSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! ListNameTableViewCell
        
        guard let seriesType = seriesType else {
            return
        }
        
        guard seriesType == .anime else {
            if let mangaListDetailViewController = storyboard?.instantiateViewController(withIdentifier: "mangaListDetailViewController") as? MangaListDetailViewController {
                mangaListDetailViewController.title = selectedCell.listNameLabel.text
                tabBarController?.navigationController?.pushViewController(mangaListDetailViewController, animated: true)
            }
            return
        }
        
        if let animeListDetailViewController = storyboard?.instantiateViewController(withIdentifier: "animeListDetailViewController") as? AnimeListDetailViewController {
            animeListDetailViewController.title = selectedCell.listNameLabel.text
            tabBarController?.navigationController?.pushViewController(animeListDetailViewController, animated: true)
        }
    }
}
