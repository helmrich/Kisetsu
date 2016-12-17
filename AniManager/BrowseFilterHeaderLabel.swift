//
//  BrowseFilterHeaderLabel.swift
//  AniManager
//
//  Created by Tobias Helmrich on 17.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class BrowseFilterHeaderLabel: AniManagerLabel {
    
    override func drawText(in rect: CGRect) {
        let edgeInsets = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 0.0)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, edgeInsets))
    }

}
