//
//  AdditionalInformationsValueLabel.swift
//  AniManager
//
//  Created by Tobias Helmrich on 05.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class AdditionalInformationsValueLabel: AniManagerLabel {
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        numberOfLines = 0
        lineBreakMode = .byWordWrapping
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
