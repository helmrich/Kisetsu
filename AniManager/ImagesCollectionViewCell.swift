//
//  ImagesCollectionViewCell.swift
//  AniManager
//
//  Created by Tobias Helmrich on 06.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class ImagesCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var id: Int?
    var type: ImagesTableViewCellType?
    var seriesType: SeriesType?
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageOverlayView: UIView!
    
    
    // MARK: - Functions
    
    override func prepareForReuse() {
        imageView.image = nil
    }
    
}
