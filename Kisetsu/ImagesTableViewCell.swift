//
//  ImagesTableViewCell.swift
//  AniManager
//
//  Created by Tobias Helmrich on 06.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class ImagesTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    var type: ImagesTableViewCellType?
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: TableViewCellTitleLabel!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var imagesCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func layoutSubviews() {
        backgroundColor = Style.Color.Background.imagesTableViewCell
        titleLabel.textColor = Style.Color.Text.tableViewCellTitle
        imagesCollectionView.backgroundColor = Style.Color.Background.collectionView
    }
}
