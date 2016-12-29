//
//  BrowseViewControllerCollectionViewDataSource.swift
//  AniManager
//
//  Created by Tobias Helmrich on 27.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit
    
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
            cell.titleLabel.isHidden = false
        }
        
        if cell.imageView.image == nil,
            let imageMediumUrlString = currentSeries.imageMediumUrlString {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            NetworkActivityManager.shared.increaseNumberOfActiveConnections()
            
            AniListClient.shared.getImageData(fromUrlString: imageMediumUrlString) { (imageData, errorMessage) in
                guard errorMessage == nil else {
                    NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                    }
                    return
                }
                
                guard let imageData = imageData else {
                    NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                    }
                    return
                }
                
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        cell.imageOverlay.isHidden = false
                        cell.imageView.image = image
                    }
                }
                
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                }
                
            }
        }
        
        return cell
        
    }
}
