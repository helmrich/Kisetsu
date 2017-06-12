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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagesCollectionViewCell", for: indexPath) as! ImagesCollectionViewCell
        cell.backgroundColor = Style.Color.Background.imagesCollectionViewCell
        
        /*
            Make sure the shared data source's selectedSeries property
            is not nil
         */
        guard let series = series else {
            return cell
        }
        
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
        
        switch imagesTableViewCellType {
        case .characters:
            /*
             Make sure the series' characters property is not nil and that
             the current character has an URL string for a medium image,
             try downloading and creating an image with the URL string and
             set the cell's image
             */
            guard let characters = series.characters else {
                return cell
            }
            
            guard let imageMediumURLString = characters[indexPath.row].imageMediumURLString,
                let imageMediumURL = URL(string: imageMediumURLString) else {
                    return cell
            }
            
            if cell.imageView.image == nil {
                cell.imageView.kf.setImage(with: imageMediumURL, placeholder: nil, options: [.transition(.fade(0.25))], progressBlock: nil) { (_, _, _, _) in
                    // TODO: App is crashing here sometimes:
                    // attempt to delete item 1 from section 0 which only contains 0 items before the update
                    collectionView.reloadItems(at: [indexPath])
                }
            }
        case .relations:
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
            if let _ = currentRelation as? AnimeSeries {
                currentRelationSeriesType = .anime
            } else if let _ = currentRelation as? MangaSeries {
                currentRelationSeriesType = .manga
            } else {
                return cell
            }
            cell.seriesType = currentRelationSeriesType
            
            let imageMediumURLString = currentRelation.imageMediumURLString
            
            guard let imageMediumURL = URL(string: imageMediumURLString) else {
                    return cell
            }
            
            if cell.imageView.image == nil {
                cell.imageView.kf.setImage(with: imageMediumURL, placeholder: UIImage.with(color: .aniManagerGray, andSize: cell.imageView.bounds.size), options: [.transition(.fade(0.25))], progressBlock: nil) { (_, _, _, _) in
                    collectionView.reloadItems(at: [indexPath])
                }
            }
        default:
            return cell
        }

        return cell
        
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
