//
//  BasicInformationsTableViewCell.swift
//  AniManager
//
//  Created by Tobias Helmrich on 30.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class BasicInformationsTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var seriesType: SeriesType = .anime
    
    let seriesCoverImageView = UIImageView()
    
    var mainStackView = UIStackView()
    
    let typeLabel = BasicInformationsLabel()
    let averageRatingLabel = BasicInformationsLabel()
    let statusLabel = BasicInformationsLabel()

    let typeValueLabel = BasicInformationsValueLabel()
    let averageRatingValueLabel = BasicInformationsValueLabel()
    let statusValueLabel = BasicInformationsValueLabel()
    
    // Anime-specific
    let seasonLabel = BasicInformationsLabel()
    let numberOfEpisodesLabel = BasicInformationsLabel()
    let durationPerEpisodeLabel = BasicInformationsLabel()
    
    let seasonValueLabel = BasicInformationsValueLabel()
    let numberOfEpisodesValueLabel = BasicInformationsValueLabel()
    let durationPerEpisodeValueLabel = BasicInformationsValueLabel()
    
    // Manga-specific
    let numberOfTotalChaptersLabel = BasicInformationsLabel()
    let numberOfTotalVolumesLabel = BasicInformationsLabel()
    
    let numberOfTotalChaptersValueLabel = BasicInformationsValueLabel()
    let numberOfTotalVolumesValueLabel = BasicInformationsValueLabel()
    
    
    // MARK: - Initializer
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = Style.Color.Background.tableViewCell
        
        // Configure the series cover image view
        seriesCoverImageView.translatesAutoresizingMaskIntoConstraints = false
        seriesCoverImageView.contentMode = .scaleAspectFill
        seriesCoverImageView.backgroundColor = .aniManagerGray
        seriesCoverImageView.clipsToBounds = true
        seriesCoverImageView.layer.cornerRadius = 2.0
        addSubview(seriesCoverImageView)
        let seriesCoverImageViewBottomConstraint = NSLayoutConstraint(item: seriesCoverImageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -15.0)
        seriesCoverImageViewBottomConstraint.priority = 999
        addConstraints([
            NSLayoutConstraint(item: seriesCoverImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 177),
            NSLayoutConstraint(item: seriesCoverImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 125.0),
            NSLayoutConstraint(item: seriesCoverImageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 15.0),
            NSLayoutConstraint(item: seriesCoverImageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 15.0),
            seriesCoverImageViewBottomConstraint
            ])
        
        // Assign values to the static labels
        typeLabel.text = "Type"
        averageRatingLabel.text = "Avg. Rating"
        statusLabel.text = "Status"
        
        // Anime-specific
        seasonLabel.text = "Season"
        numberOfEpisodesLabel.text = "Episodes"
        durationPerEpisodeLabel.text = "Duration"
        
        // Manga-specific
        numberOfTotalChaptersLabel.text = "Chapters"
        numberOfTotalVolumesLabel.text = "Volumes"
        
        /*
            Let value labels that could potentially have long texts
            adjust their font size to fit into the labels' bounding
            rectangles
         */
        statusValueLabel.adjustsFontSizeToFitWidth = true
        seasonValueLabel.adjustsFontSizeToFitWidth = true
        
        // Assign a different font to the average rating value label
        averageRatingValueLabel.font = UIFont(name: Constant.FontName.mainBlack, size: 18.0)
        
        setupStackViews(forSeriesType: seriesType)
        
    }
    
    func setupStackViews(forSeriesType seriesType: SeriesType) {
        mainStackView = UIStackView()
        
        // Create all stack views
        let typeStackView = UIStackView.createStackView(fromArrangedSubviews: [typeLabel, typeValueLabel], withAxis: .horizontal, andSpacing: 0.0)
        typeStackView.translatesAutoresizingMaskIntoConstraints = false
        let averageRatingStackView = UIStackView.createStackView(fromArrangedSubviews: [averageRatingLabel, averageRatingValueLabel], withAxis: .horizontal, andSpacing: 0.0)
        averageRatingStackView.translatesAutoresizingMaskIntoConstraints = false
        let statusStackView = UIStackView.createStackView(fromArrangedSubviews: [statusLabel, statusValueLabel], withAxis: .horizontal, andSpacing: 5.0)
        statusStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Anime-specific Stack Views
        let seasonStackView = UIStackView.createStackView(fromArrangedSubviews: [seasonLabel, seasonValueLabel], withAxis: .horizontal, andSpacing: 5.0)
        seasonStackView.translatesAutoresizingMaskIntoConstraints = false
        let numberOfEpisodesStackView = UIStackView.createStackView(fromArrangedSubviews: [numberOfEpisodesLabel, numberOfEpisodesValueLabel], withAxis: .horizontal, andSpacing: 0.0)
        numberOfEpisodesStackView.translatesAutoresizingMaskIntoConstraints = false
        let durationPerEpisodeStackView = UIStackView.createStackView(fromArrangedSubviews: [durationPerEpisodeLabel, durationPerEpisodeValueLabel], withAxis: .horizontal, andSpacing: 0.0)
        durationPerEpisodeStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Manga-specific Stack Views
        let numberOfTotalChaptersStackView = UIStackView.createStackView(fromArrangedSubviews: [numberOfTotalChaptersLabel, numberOfTotalChaptersValueLabel], withAxis: .horizontal, andSpacing: 5.0)
        numberOfTotalChaptersStackView.translatesAutoresizingMaskIntoConstraints = false
        let numberOfTotalVolumesStackView = UIStackView.createStackView(fromArrangedSubviews: [numberOfTotalVolumesLabel, numberOfTotalVolumesValueLabel], withAxis: .horizontal, andSpacing: 5.0)
        numberOfTotalVolumesStackView.translatesAutoresizingMaskIntoConstraints = false
        
        var mainStackViewArrangedSubviews = [typeStackView, averageRatingStackView, statusStackView]
        if seriesType == .anime {
            numberOfTotalChaptersStackView.removeFromSuperview()
            numberOfTotalVolumesStackView.removeFromSuperview()
            mainStackViewArrangedSubviews.append(contentsOf: [seasonStackView, numberOfEpisodesStackView, durationPerEpisodeStackView])
        } else if seriesType == .manga {
            seasonStackView.removeFromSuperview()
            numberOfEpisodesStackView.removeFromSuperview()
            durationPerEpisodeStackView.removeFromSuperview()
            mainStackViewArrangedSubviews.append(contentsOf: [numberOfTotalChaptersStackView, numberOfTotalVolumesStackView])
        }
        
        mainStackView = UIStackView.createStackView(fromArrangedSubviews: mainStackViewArrangedSubviews, withAxis: .vertical, andSpacing: 10.0)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStackView)
        addConstraints([
            NSLayoutConstraint(item: mainStackView, attribute: .leading, relatedBy: .equal, toItem: seriesCoverImageView, attribute: .trailing, multiplier: 1.0, constant: 15.0),
            NSLayoutConstraint(item: mainStackView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 15.0),
            NSLayoutConstraint(item: mainStackView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -15.0)
            ])
    }
    
    // This method hides or shows labels specific to anime series
    func set(seriesType: SeriesType) {
        self.seriesType = seriesType
        setupStackViews(forSeriesType: seriesType)
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
