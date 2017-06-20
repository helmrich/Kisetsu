//
//  SettingSwitchTableViewCell.swift
//  AniManager
//
//  Created by Tobias Helmrich on 01.01.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import UIKit

class SettingSwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var settingTextLabel: UILabel!
    @IBOutlet weak var settingSwitch: UISwitch!
    
    override func layoutSubviews() {
        backgroundColor = Style.Color.Background.tableViewCell
        settingTextLabel.textColor = Style.Color.Text.tableViewCell
    }

}
