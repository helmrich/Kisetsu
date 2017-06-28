//
//  GenreTableViewCell.swift
//  AniManager
//
//  Created by Tobias Helmrich on 03.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class GenreTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    let titleLabel = CellTitleLabel(withTitle: "Genres")
    let genreLabelStackView = UIStackView()
    
    
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
        
        // Set the genre label stack view's properties and constraints
        genreLabelStackView.translatesAutoresizingMaskIntoConstraints = false
        genreLabelStackView.axis = .vertical
        genreLabelStackView.distribution = .fillProportionally
        genreLabelStackView.spacing = 5.0
        addSubview(genreLabelStackView)
        addConstraints([
                NSLayoutConstraint(item: genreLabelStackView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: genreLabelStackView, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1.0, constant: 10.0),
                NSLayoutConstraint(item: genreLabelStackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -15.0)
            ])
        
    }
    
    
    // MARK: - Functions
    
    override func prepareForReuse() {
        /*
            All subviews of the genreLabelStackView should be removed completely
            in order to guarantee that the stack view only has the genres that belong
            to a certain series instead of just adding genres to the existing ones.
            This way every time a GenreTableViewCell is reused the genres will be
            added to an empty stack view.
         */
        for arrangedSubview in genreLabelStackView.arrangedSubviews {
            arrangedSubview.removeFromSuperview()
        }
    }

}
