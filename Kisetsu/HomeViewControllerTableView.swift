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
        
        guard indexPath.row < availableCellTypes.count else {
            return UITableViewCell(frame: .zero)
        }
        
        cellType = availableCellTypes[indexPath.row]
        cellTitle = availableCellTypes[indexPath.row].title
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(cellType.rawValue)Cell") as! ImagesTableViewCell
        
        cell.titleLabel.textColor = Style.Color.Background.imagesTableViewCellTitleLabel
        cell.activityIndicatorView.activityIndicatorViewStyle = Style.ActivityIndicatorView.lightDark
        
        cell.type = cellType
        cell.titleLabel.text = cellTitle
        cell.activityIndicatorView.startAnimatingAndFadeIn()
        
        cell.imagesCollectionView.register(UINib(nibName: "ImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "imagesCollectionViewCell")
        cell.imagesCollectionViewFlowLayout.itemSize = CGSize(width: (view.bounds.width / 3.5) > 100.0 ? 100.0 : (view.bounds.width / 3.5), height: (view.bounds.width / 3.5) > 100.0 ? 100.0 : (view.bounds.width / 3.5))
        cell.imagesCollectionViewFlowLayout.minimumLineSpacing = 1.0
        
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
        return availableCellTypes.count
    }
}
