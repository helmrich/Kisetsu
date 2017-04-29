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
        
        let selectedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagesCollectionViewCell", for: indexPath) as! ImagesCollectionViewCell
        
        // Check if the selected cell has a type
        guard let cellType = selectedCell.type else {
            return
        }
        
        /*
            Present a different detail view controller depending on the cell's type.
            
            Currently, only characters are available, thus other cases were not
            implemented yet.
         */
        switch cellType {
        case .characters:
            /*
                Get the selected character by using the index path's row property as
                an index. Then instantiate a character detail view controller
                and set its character property to the selected character
                and present the character detail view controller
             */
            guard let selectedCharacter = series?.characters?[indexPath.row] else {
                return
            }
            
            let characterDetailViewController = storyboard?.instantiateViewController(withIdentifier: "characterDetailViewController") as! CharacterDetailViewController
            characterDetailViewController.character = selectedCharacter
            if let bannerImageURL = bannerImageURL {
                characterDetailViewController.bannerImageURL = bannerImageURL
            }
            present(characterDetailViewController, animated: true, completion: nil)
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
            if let titleLanguage = UserDefaults.standard.string(forKey: "titleLanguage") {
                switch titleLanguage {
                case "english":
                    seriesDetailViewController.seriesTitle = selectedRelation.titleEnglish
                case "romaji":
                    seriesDetailViewController.seriesTitle = selectedRelation.titleRomaji
                case "japanese":
                    seriesDetailViewController.seriesTitle = selectedRelation.titleJapanese
                default:
                    seriesDetailViewController.seriesTitle = selectedRelation.titleEnglish
                }
            } else {
                seriesDetailViewController.seriesTitle = selectedRelation.titleEnglish
            }
            seriesDetailViewController.seriesId = selectedRelation.id
            present(seriesDetailViewController, animated: true, completion: nil)
        case .actors:
            break
        }
        
    }
}
