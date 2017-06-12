//
//  AniManagerLabel.swift
//  AniManager
//
//  Created by Tobias Helmrich on 05.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class AniManagerLabel: UILabel {
    
    // MARK: - Properties
    
    var hasBoldFont = false {
        didSet {
            if hasBoldFont {
                font = UIFont(name: Constant.FontName.mainBold, size: 16.0)
            } else {
                font = UIFont(name: Constant.FontName.mainLight, size: 16.0)
            }
        }
    }
    
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        font = UIFont(name: Constant.FontName.mainLight, size: 16.0)
        textColor = Style.Color.Text.aniManagerLabel
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
