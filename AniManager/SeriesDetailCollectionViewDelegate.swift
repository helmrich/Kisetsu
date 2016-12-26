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
            guard let selectedCharacter = DataSource.shared.selectedSeries?.characters?[indexPath.row] else {
                return
            }
            
            let characterDetailViewController = storyboard?.instantiateViewController(withIdentifier: "characterDetailViewController") as! CharacterDetailViewController
            characterDetailViewController.character = selectedCharacter
            present(characterDetailViewController, animated: true, completion: nil)
        case .relations:
            break
        case .actors:
            break
        }
        
    }
}
