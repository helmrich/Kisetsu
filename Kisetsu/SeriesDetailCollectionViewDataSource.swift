//
//  SeriesDetailCollectionViewDataSource.swift
//  AniManager
//
//  Created by Tobias Helmrich on 06.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

extension SeriesDetailViewController: UICollectionViewDataSource {
    /*
        The collection view delegate methods are implemented for the images table view
        cell's collection view
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        /*
            Make sure the shared data source's selectedSeries property
            is not nil
         */
        guard let series = series else {
            return UICollectionViewCell(frame: .zero)
        }
        
        /*
            Set the cell's type property to the same value as its
            collection view's table view cell's type property.
            Note: The first superview property is the table view cell's
            content view, the second one is the actual table view cell.
         */
        guard let imagesTableViewCellType = (collectionView.superview?.superview as? ImagesTableViewCell)?.type else {
            return UICollectionViewCell(frame: .zero)
        }
        
        switch imagesTableViewCellType {
        case .characters:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "characterImagesCollectionViewCell", for: indexPath) as! CharacterImagesCollectionViewCell
            cell.imagesTableViewCellType = imagesTableViewCellType
            
            /*
             Make sure the series' characters property is not nil and that
             the current character has an URL string for a medium image,
             try downloading and creating an image with the URL string and
             set the cell's image
             */
            guard let characters = series.characters else {
                return cell
            }
            
            guard let characterImageMediumURLString = characters[indexPath.row].imageMediumURLString,
                let characterImageMediumURL = URL(string: characterImageMediumURLString),
            let characterImageLargeURLString = characters[indexPath.row].imageLargeURLString,
                let characterImageLargeURL = URL(string: characterImageLargeURLString) else {
                    return cell
            }
            
            if cell.characterImageView.image == nil {
                cell.characterImageView.kf.setImage(
                with: UserDefaults.standard.bool(forKey: UserDefaultsKey.downloadHighQualityImages.rawValue) ? characterImageLargeURL : characterImageMediumURL,
                placeholder: nil, options: [.transition(.fade(0.25))], progressBlock: nil) { (_, _, _, _) in
                    // TODO: App is crashing here sometimes:
                    // attempt to delete item 1 from section 0 which only contains 0 items before the update
                    collectionView.reloadItems(at: [indexPath])
                }
            }
            
            guard let actorImageMediumURLString = characters[indexPath.row].actors?.first?.imageMediumURLString,
                let actorImageMediumURL = URL(string: actorImageMediumURLString),
                let actorImageLargeURLString = characters[indexPath.row].actors?.first?.imageLargeURLString,
                let actorImageLargeURL = URL(string: actorImageLargeURLString) else {
                    return cell
            }
            
            if cell.actorImageView.image == nil {
                cell.actorImageView.kf.setImage(
                    with: UserDefaults.standard.bool(forKey: UserDefaultsKey.downloadHighQualityImages.rawValue) ? actorImageLargeURL : actorImageMediumURL,
                    placeholder: nil, options: [.transition(.fade(0.25))], progressBlock: nil) { (_, _, _, _) in
                        // TODO: App is crashing here sometimes:
                        // attempt to delete item 1 from section 0 which only contains 0 items before the update
                        collectionView.reloadItems(at: [indexPath])
                }
            }
            
            return cell
        case .relations:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagesCollectionViewCell", for: indexPath) as! ImagesCollectionViewCell
            cell.imagesTableViewCellType = imagesTableViewCellType
            
            /*
                Check if the series' allRelations property is not nil,
                get the current relation by using the current index path's row
                as the index. Then
                check the relation's series type and set the cell's seriesType
                property depending on it. Lastly try to create an image URL
                and set the cell's image
             */
            guard let allRelations = series.allRelations else {
                return cell
            }
            
            let currentRelation = allRelations[indexPath.row]
            
            let currentRelationSeriesType: SeriesType
            if let _ = currentRelation.series as? AnimeSeries {
                currentRelationSeriesType = .anime
            } else if let _ = currentRelation.series as? MangaSeries {
                currentRelationSeriesType = .manga
            } else {
                return cell
            }
            cell.seriesType = currentRelationSeriesType
            
            if let currentRelationType = currentRelation.type {
                cell.titleLabel.text = currentRelationType
                UIView.animate(withDuration: 0.25) {
                    cell.titleLabel.alpha = 1.0
                }
            }
            
            let imageMediumURLString = currentRelation.series.imageMediumURLString
            let imageLargeURLString = currentRelation.series.imageLargeURLString
            
            guard let imageMediumURL = URL(string: imageMediumURLString),
                let imageLargeURL = URL(string: imageLargeURLString) else {
                    return cell
            }
            
            if cell.imageView.image == nil {
                cell.imageView.kf.setImage(
                with: UserDefaults.standard.bool(forKey: UserDefaultsKey.downloadHighQualityImages.rawValue) ? imageLargeURL : imageMediumURL,
                placeholder: nil, options: [.transition(.fade(0.25))], progressBlock: nil) { (_, _, _, _) in
                    collectionView.reloadItems(at: [indexPath])
                }
            }
            
            return cell
        default:
            return UICollectionViewCell(frame: .zero)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let imagesTableViewCellType = (collectionView.superview?.superview as? ImagesTableViewCell)?.type else {
            return 0
        }

        switch imagesTableViewCellType {
        case .characters:
            // The number of items should be equal to the number of series characters
            guard let characters = series?.characters else {
                return 0
            }
            
            return characters.count
        case .relations:
            // The number of items should be equal to the number of relations
            guard let allRelations = series?.allRelations else {
                return 0
            }
            
            return allRelations.count
        default:
            return 0
        }
    }
}
