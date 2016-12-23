//
//  DescriptionTableViewCell.swift
//  AniManager
//
//  Created by Tobias Helmrich on 30.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class DescriptionTableViewCell: UITableViewCell {
    
    fileprivate let titleLabel = TableViewCellTitleLabel(withTitle: "Description")
    let descriptionTextView = UITextView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Set the title label and description text views' properties
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.font = UIFont(name: Constant.FontName.mainRegular, size: 14.0)
        descriptionTextView.textColor = .aniManagerBlack
        descriptionTextView.isEditable = false
        descriptionTextView.isSelectable = false
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.textAlignment = .justified
        descriptionTextView.textContainer.lineFragmentPadding = 0
        
        // Set the title label and description text views' constraints
        addSubview(titleLabel)
        addSubview(descriptionTextView)
        addConstraints([
                NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: descriptionTextView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: descriptionTextView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -15.0),
                NSLayoutConstraint(item: descriptionTextView, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: descriptionTextView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -15.0)
            ])
    }

}
