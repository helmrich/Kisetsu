//
//  SeriesCollectionViewCell.swift
//  AniManager
//
//  Created by Tobias Helmrich on 25.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class SeriesCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    
    var seriesId: Int?
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var imageOverlay: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        seriesId = nil
        imageView.image = nil
        imageOverlay.alpha = 0.0
        titleLabel.alpha = 0.0
    }
}
