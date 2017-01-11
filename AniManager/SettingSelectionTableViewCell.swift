//
//  SettingSelectionTableViewCell.swift
//  AniManager
//
//  Created by Tobias Helmrich on 11.01.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import UIKit

class SettingSelectionTableViewCell: UITableViewCell {
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            textLabel?.alpha = 1.0
            contentView.backgroundColor = .aniManagerGray
        } else {
            textLabel?.alpha = 0.3
        }
    }
}
