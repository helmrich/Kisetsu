//
//  EpisodesTableViewCell.swift
//  Kisetsu
//
//  Created by Tobias Helmrich on 24.06.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import UIKit

class EpisodesTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    let titleLabel = CellTitleLabel(withTitle: "Episodes")
    let seeAllEpisodesButton = AniManagerButton()
    
    
    // MARK: - Initializer
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Set the title label's constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addConstraints([
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 15.0),
            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 15.0),
        ])
        
        seeAllEpisodesButton.set(enabled: false)
        seeAllEpisodesButton.setTitle("See all Episodes", for: .normal)
        seeAllEpisodesButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(seeAllEpisodesButton)
        seeAllEpisodesButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15.0).isActive = true
        seeAllEpisodesButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15.0).isActive = true
        seeAllEpisodesButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15.0).isActive = true
        seeAllEpisodesButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15.0).isActive = true
        seeAllEpisodesButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
    }
}
