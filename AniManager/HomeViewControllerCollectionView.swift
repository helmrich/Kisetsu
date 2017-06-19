//
//  HomeViewControllerCollectionView.swift
//  AniManager
//
//  Created by Tobias Helmrich on 01.06.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Data Source

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagesCollectionViewCell", for: indexPath) as! ImagesCollectionViewCell
        
        /*
            These properties have to be set in order for Auto Layout
            to work properly for UICollectionViewCell subclasses on
            all devices. The problem was especially visible for the
            labels in images collection view cells when using an iPhone SE
         
            Also see stackoverflow: https://stackoverflow.com/a/27500590
         */
        cell.contentView.frame = cell.bounds
        cell.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        cell.imageOverlayView.alpha = 0.6
        
        /*
         Set the cell's type property to the same value as its
         collection view's table view cell's type property.
         Note: The first superview property is the table view cell's
         content view, the second one is the actual table view cell.
         */
        guard let imagesTableViewCellType = (collectionView.superview?.superview as? ImagesTableViewCell)?.type else {
            return cell
        }
        
        cell.imagesTableViewCellType = imagesTableViewCellType
        
        let seriesList = getSeriesList(forCellOfType: imagesTableViewCellType)
        
        guard seriesList.count > 0,
            seriesList.count > indexPath.row else {
                return cell
        }
        
        let currentSeries = seriesList[indexPath.row]
        
        guard let imageMediumURL = URL(string: currentSeries.imageMediumURLString),
            let imageLargeURL = URL(string: currentSeries.imageLargeURLString) else {
            return cell
        }
        
        cell.titleLabel.text = currentSeries.titleForSelectedTitleLanguageSetting
        
        if let currentAnimeSeries = currentSeries as? AnimeSeries,
            let timeInSecondsUntilNextEpisode = currentAnimeSeries.countdownUntilNextEpisodeInSeconds,
         let nextEpisodeNumber = currentAnimeSeries.nextEpisodeNumber {
            let hoursUntilNextEpisode = Double(timeInSecondsUntilNextEpisode) / 3600.0
            let nextEpisodeString: String
            if hoursUntilNextEpisode > 24.0 {
                let amountOfDays = Int(round(hoursUntilNextEpisode / 24.0))
                nextEpisodeString = "New episode \(nextEpisodeNumber) in \(amountOfDays) \(amountOfDays > 1 ? "days" : "day")"
            } else {
                let amountOfHours = Int(round(hoursUntilNextEpisode))
                nextEpisodeString = "New episode \(nextEpisodeNumber) in \(amountOfHours) \(amountOfHours > 1 ? "hours" : "hour")"
            }
            cell.nextEpisodeLabel.text = nextEpisodeString
            UIView.animate(withDuration: 0.25) {
                cell.nextEpisodeLabel.alpha = 1.0
            }
        }
        UIView.animate(withDuration: 0.25) {
            cell.titleLabel.alpha = 1.0
        }
        
        if cell.imageView.image == nil {
            cell.imageView.kf.setImage(
                with: UserDefaults.standard.bool(forKey: UserDefaultsKey.downloadHighQualityImages.rawValue) ? imageLargeURL : imageMediumURL,
            placeholder: nil, options: [.transition(.fade(0.25))], progressBlock: nil) { (_, _, _, _) in
                collectionView.reloadItems(at: [indexPath])
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let imagesTableViewCellType = (collectionView.superview?.superview as? ImagesTableViewCell)?.type else {
            return 0
        }
        
        let seriesList = getSeriesList(forCellOfType: imagesTableViewCellType)
        
        if seriesList.count == 0 {
            return 0
        }
        
        return seriesList.count
        
    }
}


// MARK: - Delegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagesCollectionViewCell", for: indexPath) as! ImagesCollectionViewCell
        guard let cellType = cell.imagesTableViewCellType else {
            return
        }
        
        let seriesList = getSeriesList(forCellOfType: cellType)
        
        guard indexPath.row < seriesList.count else {
            return
        }
        
        let selectedSeries = seriesList[indexPath.row]
        
        let seriesTitle = selectedSeries.titleForSelectedTitleLanguageSetting
        
        presentSeriesDetail(forSeriesWithId: seriesList[indexPath.row].id, seriesTitle: seriesTitle, seriesType: seriesList[indexPath.row].seriesType)
        
    }
}
