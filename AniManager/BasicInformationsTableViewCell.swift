//
//  BasicInformationsTableViewCell.swift
//  AniManager
//
//  Created by Tobias Helmrich on 30.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class BasicInformationsTableViewCell: UITableViewCell {
    
    let seriesCoverImageView = UIImageView()
    
    let typeLabel = BasicInformationsLabel()
    let averageRatingLabel = BasicInformationsLabel()
    let statusLabel = BasicInformationsLabel()
    let seasonLabel = BasicInformationsLabel()
    let numberOfEpisodesLabel = BasicInformationsLabel()
    let durationPerEpisodeLabel = BasicInformationsLabel()

    let typeValueLabel = BasicInformationsValueLabel()
    let averageRatingValueLabel = BasicInformationsValueLabel()
    let statusValueLabel = BasicInformationsValueLabel()
    let seasonValueLabel = BasicInformationsValueLabel()
    let numberOfEpisodesValueLabel = BasicInformationsValueLabel()
    let durationPerEpisodeValueLabel = BasicInformationsValueLabel()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        seriesCoverImageView.translatesAutoresizingMaskIntoConstraints = false
        seriesCoverImageView.contentMode = .scaleAspectFill
        addSubview(seriesCoverImageView)
        addConstraints([
            NSLayoutConstraint(item: seriesCoverImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 177),
            NSLayoutConstraint(item: seriesCoverImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 125),
            NSLayoutConstraint(item: seriesCoverImageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: seriesCoverImageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 15.0),
            NSLayoutConstraint(item: seriesCoverImageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -15.0)
            ])
        
        typeLabel.text = "Type"
        averageRatingLabel.text = "Avg. Rating"
        statusLabel.text = "Status"
        seasonLabel.text = "Season"
        numberOfEpisodesLabel.text = "Episodes"
        durationPerEpisodeLabel.text = "Duration"
        
        averageRatingValueLabel.font = UIFont(name: "Lato-Black", size: 18.0)
        
        let typeStackView = UIStackView.createStackView(fromArrangedSubviews: [typeLabel, typeValueLabel], withAxis: .horizontal, andSpacing: 0.0)
        typeStackView.translatesAutoresizingMaskIntoConstraints = false
        let averageRatingStackView = UIStackView.createStackView(fromArrangedSubviews: [averageRatingLabel, averageRatingValueLabel], withAxis: .horizontal, andSpacing: 0.0)
        averageRatingStackView.translatesAutoresizingMaskIntoConstraints = false
        let statusStackView = UIStackView.createStackView(fromArrangedSubviews: [statusLabel, statusValueLabel], withAxis: .horizontal, andSpacing: 0.0)
        statusStackView.translatesAutoresizingMaskIntoConstraints = false
        let seasonStackView = UIStackView.createStackView(fromArrangedSubviews: [seasonLabel, seasonValueLabel], withAxis: .horizontal, andSpacing: 0.0)
        seasonStackView.translatesAutoresizingMaskIntoConstraints = false
        let numberOfEpisodesStackView = UIStackView.createStackView(fromArrangedSubviews: [numberOfEpisodesLabel, numberOfEpisodesValueLabel], withAxis: .horizontal, andSpacing: 0.0)
        numberOfEpisodesStackView.translatesAutoresizingMaskIntoConstraints = false
        let durationPerEpisodeStackView = UIStackView.createStackView(fromArrangedSubviews: [durationPerEpisodeLabel, durationPerEpisodeValueLabel], withAxis: .horizontal, andSpacing: 0.0)
        durationPerEpisodeStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let mainStackView = UIStackView.createStackView(fromArrangedSubviews: [typeStackView, averageRatingStackView, statusStackView, seasonStackView, numberOfEpisodesStackView, durationPerEpisodeStackView], withAxis: .vertical, andSpacing: 10.0)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStackView)
        addConstraints([
                NSLayoutConstraint(item: mainStackView, attribute: .leading, relatedBy: .equal, toItem: seriesCoverImageView, attribute: .trailing, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: mainStackView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: mainStackView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -15.0)
            ])
        
        
    }
    
    override func prepareForReuse() {
        seriesCoverImageView.image = nil
        typeValueLabel.text = ""
        averageRatingValueLabel.text = ""
        statusValueLabel.text = ""
        seasonValueLabel.text = ""
        numberOfEpisodesValueLabel.text = ""
        durationPerEpisodeValueLabel.text = ""
    }

}
