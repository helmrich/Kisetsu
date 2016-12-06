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
            guard let selectedCharacterId = DataSource.shared.selectedSeries?.characters?[indexPath.row].id else {
                return
            }
            
            // TODO: Present character detail view controller
        case .relations:
            break
        case .actors:
            break
        }
        
    }
}
