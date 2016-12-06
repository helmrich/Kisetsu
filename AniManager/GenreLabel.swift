//
//  GenreLabel.swift
//  AniManager
//
//  Created by Tobias Helmrich on 03.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class GenreLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        font = UIFont(name: Constant.FontName.mainRegular, size: 16.0)
        backgroundColor = .aniManagerBlack
        textColor = .white
        textAlignment = .center
        layer.cornerRadius = 2.0
    }
    
    override var intrinsicContentSize: CGSize {
        let contentSize = super.intrinsicContentSize
        return CGSize(width: contentSize.width + 20, height: contentSize.height + 10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

}
