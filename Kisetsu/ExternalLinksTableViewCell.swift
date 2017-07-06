//
//  ExternalLinksTableViewCell.swift
//  AniManager
//
//  Created by Tobias Helmrich on 09.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class ExternalLinksTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    var externalLinks = [ExternalLink]()
    var maximumNumberOfButtonsPerRow = 2
    let titleLabel = CellTitleLabel(withTitle: "External Links")
    
    
    // MARK: - Initializer
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = Style.Color.Background.tableViewCell
        
        // Configure the title label and set its constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addConstraints([
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 15.0),
            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 15.0)
            ])
    }
    
    
    // MARK: - Functions
    
    func setupCell() {
        // Create a vertical main stack view that will contain all button stack views
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 5.0
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStackView)
        addConstraints([
            NSLayoutConstraint(item: mainStackView, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: mainStackView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 15.0),
            NSLayoutConstraint(item: mainStackView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -15.0),
            NSLayoutConstraint(item: mainStackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -15.0)
            ])
        
        // Create empty button and stack view arrays
        var buttons = [ExternalLinkButton]()
        var stackViews = [UIStackView]()
        
        // Loop over all items that should get a button
        for (index, externalLink) in externalLinks.enumerated() {
            // Create and configure a button and append it to the array of buttons
            let button = ExternalLinkButton()
            button.setTitle(externalLink.siteName, for: .normal)
            button.siteURLString = externalLink.siteURLString
            button.translatesAutoresizingMaskIntoConstraints = false
            buttons.append(button)
            
            /*
             If the index of the current iteration item is equal to the number
             of items that should get a button - 1 the current item is the last
             item. A final stack view should be created that should contain the
             last button(s). This condition has to be checked because otherwise
             a stack view wouldn't be created if the number of buttons is less
             than the maximal number of buttons that should be in one horizontal
             stack view.
             */
            if index == externalLinks.count - 1 {
                let stackView = UIStackView(arrangedSubviews: buttons)
                stackView.axis = .horizontal
                stackView.spacing = 5.0
                stackView.distribution = .fillEqually
                stackView.translatesAutoresizingMaskIntoConstraints = false
                stackViews.append(stackView)
                break
            }
            
            /*
             If the number of buttons is equal to the number of maximum buttons per row
             a stack view should be created and filled with all the buttons. After that
             the buttons array should be reset to an empty array so that it can be filled
             with new buttons for the next stack view.
             */
            if buttons.count == maximumNumberOfButtonsPerRow {
                let stackView = UIStackView(arrangedSubviews: buttons)
                stackView.axis = .horizontal
                stackView.spacing = 5.0
                stackView.distribution = .fillEqually
                stackView.translatesAutoresizingMaskIntoConstraints = false
                stackViews.append(stackView)
                buttons = [ExternalLinkButton]()
            }
        }
        
        // Loop over all stack views and add them to the main stack view
        for stackView in stackViews {
            mainStackView.addArrangedSubview(stackView)
        }
    }

}
