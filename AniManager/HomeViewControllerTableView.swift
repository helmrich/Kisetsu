//
//  HomeViewControllerTableView.swift
//  AniManager
//
//  Created by Tobias Helmrich on 01.06.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import Foundation
import UIKit

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellTitle: String
        let cellType: ImagesTableViewCellType
        
        if indexPath.row == 0 {
            cellType = .currentlyAiring
            cellTitle = "Currently Airing"
        } else if indexPath.row == 1 {
            cellType = .currentSeason
            cellTitle = "Current Season"
        } else if indexPath.row == 2 {
            cellType = .mostPopularAnime
            cellTitle = "Most Popular Anime"
        } else if indexPath.row == 3 {
            cellType = .topRatedAnime
            cellTitle = "Top Rated Anime"
        } else if indexPath.row == 4 {
            cellType = .mostPopularManga
            cellTitle = "Most Popular Manga"
        } else if indexPath.row == 5 {
            cellType = .topRatedManga
            cellTitle = "Top Rated Manga"
        } else if indexPath.row == 6 {
            cellType = .continueWatching
            cellTitle = "Continue Watching"
        } else if indexPath.row == 7 {
            cellType = .continueReading
            cellTitle = "Continue Reading"
        } else {
            return UITableViewCell(frame: CGRect.zero)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(cellType.rawValue)Cell") as! ImagesTableViewCell
        
        cell.titleLabel.textColor = Style.Color.Background.imagesTableViewCellTitleLabel
        cell.activityIndicatorView.activityIndicatorViewStyle = Style.ActivityIndicatorView.lightDark
        
        cell.type = cellType
        cell.titleLabel.text = cellTitle
        cell.activityIndicatorView.startAnimatingAndFadeIn()
        
        cell.imagesCollectionView.register(UINib(nibName: "ImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "imagesCollectionViewCell")
        cell.imagesCollectionViewFlowLayout.itemSize = CGSize(width: (view.bounds.width / 3.5) > 100 ? 100 : (view.bounds.width / 3.5), height: (view.bounds.width / 3.5) > 100 ? 100 : (view.bounds.width / 3.5))
        cell.imagesCollectionViewFlowLayout.minimumLineSpacing = 1
        
        cell.imagesCollectionView.dataSource = self
        cell.imagesCollectionView.delegate = self
        
        cell.imagesCollectionView.backgroundColor = Style.Color.Background.imagesCollectionViewCell
        
        
        cell.imagesCollectionView.reloadData()
        if cell.imagesCollectionView.numberOfItems(inSection: 0) > 0 {
            cell.activityIndicatorView.stopAnimatingAndFadeOut()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let grantTypeString = UserDefaults.standard.string(forKey: "grantType"),
            let grantType = GrantType(rawValue: grantTypeString) else {
                return DataSource.shared.notLoggedInSeriesLists.count
        }
        
        if grantType == .clientCredentials {
            return DataSource.shared.notLoggedInSeriesLists.count
        } else {
            return DataSource.shared.allSeriesLists.count
        }
    }
}
