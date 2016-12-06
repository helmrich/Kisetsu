//
//  ImagesTableViewCell.swift
//  AniManager
//
//  Created by Tobias Helmrich on 06.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class ImagesTableViewCell: UITableViewCell {

    var type: ImagesTableViewCellType?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var imagesCollectionViewFlowLayout: UICollectionViewFlowLayout!
    
}
