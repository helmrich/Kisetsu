//
//  SeriesDetailCollectionViewDelegate.swift
//  AniManager
//
//  Created by Tobias Helmrich on 06.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

extension SeriesDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagesCollectionViewCell", for: indexPath) as! ImagesCollectionViewCell
        
        guard let cellType = selectedCell.type else {
            return
        }
        
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
