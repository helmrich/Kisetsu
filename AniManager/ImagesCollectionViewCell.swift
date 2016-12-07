//
//  ImagesCollectionViewCell.swift
//  AniManager
//
//  Created by Tobias Helmrich on 06.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class ImagesCollectionViewCell: UICollectionViewCell {
    var id: Int?
    var type: ImagesTableViewCellType?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageOverlayView: UIView!
    
}
