//
//  CellTitleLabel.swift
//  AniManager
//
//  Created by Tobias Helmrich on 05.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class CellTitleLabel: AniManagerLabel {
    
    // MARK: - Initializer
    
    convenience init(withTitle title: String) {
        self.init()
        text = title
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        font = UIFont(name: Constant.FontName.mainBlack, size: 24.0)
        textAlignment = .left
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
