//
//  CharacterImagesCollectionViewCell.swift
//  Kisetsu
//
//  Created by Tobias Helmrich on 28.06.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import UIKit

class CharacterImagesCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    
    var id: Int?
    var imagesTableViewCellType: ImagesTableViewCellType?
    var lastTouchYPosition: CGFloat? {
        didSet {
            guard let lastTouchYPosition = lastTouchYPosition else { return }
            selectionType = lastTouchYPosition >= CGFloat(100.0) ? .staff : .character
        }
    }
    var selectionType: PersonType?
    
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var characterImageView: UIImageView!
    @IBOutlet weak var actorImageView: UIImageView!
    
    
    // MARK: - Lifecycle Methods
    override func layoutSubviews() {
        backgroundColor = Style.Color.Background.imagesCollectionViewCell
        characterImageView.backgroundColor = Style.Color.Background.imagesCollectionViewCell
        actorImageView.backgroundColor = Style.Color.Background.imagesCollectionViewCell
    }
    
    override func prepareForReuse() {
        characterImageView.image = nil
        actorImageView.image = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        lastTouchYPosition = touch?.location(in: self).y
        super.touchesBegan(touches, with: event)
    }
}
