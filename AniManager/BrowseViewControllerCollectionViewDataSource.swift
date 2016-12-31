//
//  BrowseViewControllerCollectionViewDataSource.swift
//  AniManager
//
//  Created by Tobias Helmrich on 27.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit
import Kingfisher
    
extension BrowseViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfBasicSeriesInBrowseList
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seriesCell", for: indexPath) as! SeriesCollectionViewCell
        
        guard let browseList = browseList,
            let basicSeries = browseList.basicSeries else {
                return cell
        }
        
        guard numberOfBasicSeriesInBrowseList > indexPath.row else {
            return cell
        }
        
        /*
         Get the current series from the browse series list,
         if the cell doesn't have a series ID, assign the current
         series' ID to the cells seriesId property and set the
         cell's title label to the current series' title and
         show it
         
         Then download the cover image and set the cell's image
         view's image property to the received image
         */
        guard let currentSeries = basicSeries[indexPath.row] as? BasicSeries else {
            return cell
        }
        
        if cell.seriesId == nil {
            cell.seriesId = Int(currentSeries.id)
        }
        
        DispatchQueue.main.async {
            cell.titleLabel.text = currentSeries.titleEnglish
            cell.titleLabel.alpha = 1.0
            cell.imageOverlay.alpha = 0.7
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        NetworkActivityManager.shared.increaseNumberOfActiveConnections()
        
        if cell.imageView.image == nil,
            let imageMediumUrlString = currentSeries.imageMediumUrlString,
            let imageMediumUrl = URL(string: imageMediumUrlString) {
            cell.imageView.kf.setImage(with: imageMediumUrl, placeholder: UIImage.with(color: .aniManagerGray, andSize: cell.imageView.bounds.size), options: [.transition(.fade(0.25))], progressBlock: nil) { (_, _, _, _) in
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
            }
        }
        
        return cell
        
    }
}







