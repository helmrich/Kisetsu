//
//  FilterValueTableViewCell.swift
//  AniManager
//
//  Created by Tobias Helmrich on 29.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class FilterValueTableViewCell: UITableViewCell {

    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var filterValueLabel: UILabel!
    
    override func layoutSubviews() {
        backgroundColor = Style.Color.Background.tableViewCell
        filterValueLabel.textColor = Style.Color.Text.tableViewCell
    }
}
