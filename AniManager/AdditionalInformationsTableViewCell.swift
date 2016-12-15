//
//  AdditionalInformationsTableViewCell.swift
//  AniManager
//
//  Created by Tobias Helmrich on 05.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class AdditionalInformationsTableViewCell: UITableViewCell {

    fileprivate let titleLabel = TableViewCellTitleLabel(withTitle: "Additional Informations")
    
    let studioLabel = AniManagerLabel()
    let englishTitleLabel = AniManagerLabel()
    let romajiTitleLabel = AniManagerLabel()
    let japaneseTitleLabel = AniManagerLabel()
    let synonymsLabel = AniManagerLabel()
    
    let studioValueLabel = AdditionalInformationsValueLabel()
    let englishTitleValueLabel = AdditionalInformationsValueLabel()
    let romajiTitleValueLabel = AdditionalInformationsValueLabel()
    let japaneseTitleValueLabel = AdditionalInformationsValueLabel()
    let synonymsValueLabel = AdditionalInformationsValueLabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addConstraints([
                NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 15.0),
            ])
        
        
        studioLabel.hasBoldFont = true
        studioLabel.text = "Studios"
        englishTitleLabel.hasBoldFont = true
        englishTitleLabel.text = "English"
        romajiTitleLabel.hasBoldFont = true
        romajiTitleLabel.text = "Romaji"
        japaneseTitleLabel.hasBoldFont = true
        japaneseTitleLabel.text = "Japanese"
        synonymsLabel.hasBoldFont = true
        synonymsLabel.text = "Synonyms"
        
        
        let studioStackView = UIStackView.createStackView(fromArrangedSubviews: [studioLabel, studioValueLabel], withAxis: .vertical, andSpacing: 0.0)
        let englishTitleStackView = UIStackView.createStackView(fromArrangedSubviews: [englishTitleLabel, englishTitleValueLabel], withAxis: .vertical, andSpacing: 0.0)
        let romajiTitleStackView = UIStackView.createStackView(fromArrangedSubviews: [romajiTitleLabel, romajiTitleValueLabel], withAxis: .vertical, andSpacing: 0.0)
        let japaneseTitleStackView = UIStackView.createStackView(fromArrangedSubviews: [japaneseTitleLabel, japaneseTitleValueLabel], withAxis: .vertical, andSpacing: 0.0)
        let synonymsStackView = UIStackView.createStackView(fromArrangedSubviews: [synonymsLabel, synonymsValueLabel], withAxis: .vertical, andSpacing: 0.0)
        
        let mainStackView = UIStackView.createStackView(fromArrangedSubviews: [
                studioStackView,
                englishTitleStackView,
                romajiTitleStackView,
                japaneseTitleStackView,
                synonymsStackView
            ], withAxis: .vertical, andSpacing: 5.0)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStackView)
        addConstraints([
                NSLayoutConstraint(item: mainStackView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: mainStackView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -15.0),
                NSLayoutConstraint(item: mainStackView, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1.0, constant: 5.0),
                NSLayoutConstraint(item: mainStackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -15.0)
            ])
        
    }

}
