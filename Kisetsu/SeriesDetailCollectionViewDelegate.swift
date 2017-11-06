//
//  SeriesDetailCollectionViewDelegate.swift
//  AniManager
//
//  Created by Tobias Helmrich on 06.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

extension SeriesDetailViewController: UICollectionViewDelegate {
    /*
        The collection view delegate method is implemented for the images table view
        cell's collection view
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let imagesTableViewCellSuperview = collectionView.superview?.superview as? ImagesTableViewCell else {
            return
        }
        
        /*
            Check if the images table view cell the cell's collection view is
            contained in has a cell type
         */
        guard let imagesTableViewCellType = imagesTableViewCellSuperview.type else {
            return
        }
        
        /*
            Present a different detail view controller depending on the cell's type.
            
            Currently, only characters are available, thus other cases were not
            implemented yet.
         */
        switch imagesTableViewCellType {
        case .characters:
            let selectedCell = collectionView.cellForItem(at: indexPath) as! CharacterImagesCollectionViewCell
            
            guard let selectedCellSelectionType = selectedCell.selectionType else {
                return
            }
            
            guard let personDetailViewController = storyboard?.instantiateViewController(withIdentifier: "personDetailViewController") as? PersonDetailViewController else {
                return
            }
            
            if let bannerImageURL = bannerImageURL {
                personDetailViewController.bannerImageURL = bannerImageURL
            }
            
            switch selectedCellSelectionType {
            case .character:
                /*
                 Get the selected character by using the index path's row property as
                 an index. Then instantiate a character detail view controller
                 and set its character property to the selected character
                 and present the character detail view controller
                 */
                guard let selectedCharacter = series?.characters?[indexPath.row] else {
                    return
                }
                
                personDetailViewController.character = selectedCharacter
            case .staff:
                guard let selectedActor = series?.characters?[indexPath.row].actors?.first else {
                    return
                }
                
                personDetailViewController.staff = selectedActor
            }
            present(personDetailViewController, animated: true, completion: nil)
        case .relations:
            /*
                Get the selected relation by using the index path's row property as
                an index. Then instantiate a series detail view controller
                and set its properties to the relation's appropriate values and
                present the series detail view controller
             */
            guard let selectedRelation = series?.allRelations?[indexPath.row] else {
                return
            }
            
            let seriesDetailViewController = storyboard?.instantiateViewController(withIdentifier: "seriesDetailViewController") as! SeriesDetailViewController
            seriesDetailViewController.seriesType = (collectionView.cellForItem(at: indexPath) as! ImagesCollectionViewCell).seriesType
                seriesDetailViewController.seriesTitle = selectedRelation.series.titleForSelectedTitleLanguageSetting
            seriesDetailViewController.seriesId = selectedRelation.series.id
            present(seriesDetailViewController, animated: true, completion: nil)
        case .actors:
            break
        default:
            break
        }
    }
}
