//
//  SeriesDetailViewControllerTableViewDataSource.swift
//  AniManager
//
//  Created by Tobias Helmrich on 14.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

extension SeriesDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let availableCellTypes = availableCellTypes else {
            return 0
        }
        
        return availableCellTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let series = series,
        let availableCellTypes = availableCellTypes else {
            return UITableViewCell(frame: CGRect.zero)
        }
        
        let currentCellType = availableCellTypes[indexPath.row]
        
        switch currentCellType {
        case .basicInformations:
            // MARK: - Basic Informations Cell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicInformationsCell") as! BasicInformationsTableViewCell
            cell.backgroundColor = Style.Color.Background.tableViewCell
            
            /*
                Try to get the large image from the series' URL string and
                set the cell's cover image when the image data could be
                downloaded and turned into an image successfully
             */
            
            NetworkActivityManager.shared.increaseNumberOfActiveConnections()
            
            if let imageLargeURL = URL(string: series.imageLargeURLString) {
                cell.seriesCoverImageView.kf.setImage(with: imageLargeURL, placeholder: UIImage.with(color: .aniManagerGray, andSize: CGSize(width: 125.0, height: 177.0)), options: [.transition(.fade(0.25))], progressBlock: nil) { (_, _, _, _) in
                    NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                }
            } else {
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
            }
            
            // Set cell property values that both series types have
            cell.averageRatingValueLabel.text = "\(Int(round(series.averageScore)))"
            
            /*
                Set the cell's average rating value label's color depending on
                the score
             */
            switch series.averageScore {
            case _ where series.averageScore > 75:
                cell.averageRatingValueLabel.textColor = .aniManagerGreen
            case _ where series.averageScore > 59:
                cell.averageRatingValueLabel.textColor = .aniManagerLightGreen
            case _ where series.averageScore > 39:
                cell.averageRatingValueLabel.textColor = .aniManagerYellow
            case _ where series.averageScore >= 0:
                cell.averageRatingValueLabel.textColor = .aniManagerRed
            default:
                cell.averageRatingValueLabel.textColor = .aniManagerBlack
            }
            
            cell.typeValueLabel.text = series.mediaType.rawValue
            
            // Set specific property values depending on the series type
            switch series.seriesType {
            case .anime:
                let animeSeries = series as! AnimeSeries
                cell.set(seriesType: .anime)
                cell.statusValueLabel.text = animeSeries.airingStatus != nil ? animeSeries.airingStatus!.rawValue : "n/a"
                cell.durationPerEpisodeValueLabel.text = animeSeries.durationPerEpisode != nil ? "\(animeSeries.durationPerEpisode!)min" : "n/a"
                cell.numberOfEpisodesValueLabel.text = "\(animeSeries.numberOfTotalEpisodes)"
                let seasonString = createSeasonString(fromSeasonId: animeSeries.seasonId)
                cell.seasonValueLabel.text = seasonString != nil ? seasonString : "n/a"
                
                /*
                    layoutSubviews has to be called so that the the cell's labels
                    with dynamic content will update their width based on the values
                 */
                cell.layoutSubviews()
                return cell
            case .manga:
                let mangaSeries = series as! MangaSeries
                cell.statusValueLabel.text = mangaSeries.publishingStatus?.rawValue
                cell.set(seriesType: .manga)
                cell.numberOfTotalChaptersValueLabel.text = "\(mangaSeries.numberOfTotalChapters)"
                cell.numberOfTotalVolumesValueLabel.text = "\(mangaSeries.numberOfTotalVolumes)"
                
                /*
                    layoutSubviews has to be called so that the the cell's labels
                    with dynamic content will update their width based on the values
                 */
                cell.layoutSubviews()
                return cell
            }
        case .actions:
            // MARK: - Actions Cell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell") as! ActionsTableViewCell
            cell.backgroundColor = Style.Color.Background.tableViewCell
            
            /*
                - Add a target-action to the rate button that will show
                the rating picker when tapped
                - Addd a target-action to the user list status button that
                shows the available lists in an alert controller when tapped
                - Add a toolbar input accessory view to all progress text fields
             */
            cell.rateButton.addTarget(self, action: #selector(toggleRatingPickerVisibility), for: [.touchUpInside])
            cell.userListStatusButton.addTarget(self, action: #selector(showLists), for: [.touchUpInside])
            cell.addToolbarInputAccessoryViewToProgressTextFields(doneButtonTarget: self, doneButtonAction: #selector(progressTextFieldWasEdited))
            
            /*
                First, get the authenticated user in order to be able to request
                list informations for the user's ID
             */
            
            NetworkActivityManager.shared.increaseNumberOfActiveConnections()
            
            /*
                Check which grant type was used to authenticate and only try
                to get the authenticated user and list informations when the
                user is logged in, thus client credentials were NOT used to
                authenticate
             */
            if let grantType = grantType,
                grantType != .clientCredentials {
                AniListClient.shared.getAuthenticatedUser { (user, errorMessage) in
                    
                    // Error Handling
                    guard errorMessage == nil else {
                        self.errorMessageView.showAndHide(withMessage: errorMessage!)
                        NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                        return
                    }
                    
                    guard let user = user else {
                        self.errorMessageView.showAndHide(withMessage: "Couldn't get authenticated user")
                        NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                        return
                    }
                    
                    /*
                     Get list informations for the authenticated user whose information was
                     requested before
                     */
                    AniListClient.shared.getListInformations(forSeriesOfType: self.seriesType, withId: self.seriesId, forUserId: user.id, forDisplayName: nil) { (status, userScore, episodesWatched, readChapters, readVolumes, errorMessage) in
                        
                        // Error Handling
                        guard errorMessage == nil else {
                            /*
                                 Assume that the series is not in a list when an error
                                 is received and set up the cell appropriately, i.e.
                                 deactivate elements that should not be usable when a
                                 series isn't in a list (rate button, progress-related
                                 elements)
                             */
                            cell.setupCell(forGrantType: grantType, seriesType: self.seriesType, isSeriesInList: false)
                            NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                            return
                        }
                        
                        DispatchQueue.main.async {
                            // Set the user list status button's title
                            if let status = status {
                                cell.userListStatusButton.setTitle(status.capitalized, for: .normal)
                            }
                            
                            /*
                                 When a user score is available and it's higher than 0,
                                 set the button's title to "Your Rating: <USERRATING>"
                                 and also pre-select the corresponding value in the rating
                                 picker view so that it's already selected when the rating
                                 picker will be shown
                             */
                            if let userScore = userScore,
                                userScore > 0 {
                                cell.rateButton.setTitle("Your Rating: \(userScore)", for: .normal)
                                self.ratingPicker?.pickerView.selectRow(userScore - 1, inComponent: 0, animated: false)
                            }
                            
                            /*
                             Set the appropriate progress text fields depending on the
                             series type (watched episodes text field for anime, read
                             chapters and volumes for manga)
                             */
                            if self.seriesType == .anime {
                                if let episodesWatched = episodesWatched {
                                    cell.watchedEpisodesTextField.text = "\(episodesWatched)"
                                }
                            } else if self.seriesType == .manga {
                                if let readChapters = readChapters {
                                    cell.chaptersReadTextField.text = "\(readChapters)"
                                }
                                
                                if let readVolumes = readVolumes {
                                    cell.volumesReadTextField.text = "\(readVolumes)"
                                }
                            }
                            
                            NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                            cell.setupCell(forGrantType: grantType, seriesType: self.seriesType, isSeriesInList: true)
                        }
                    }
                }
            }
            
            /*
                Configure the maximum number of <UNIT>-labels and add target-actions
                to the belonging buttons. To get the buttons a loop should iterate
                over all arranged subviews in the appropriate stack view and check
                if the arranged subview can be casted to the UIButton type. The target-
                actions should be added to those buttons as the progress-related
                buttons are the only buttons in those stack views
             */
            if let animeSeries = series as? AnimeSeries {
                cell.maximumNumberOfEpisodesLabel.text = "\(animeSeries.numberOfTotalEpisodes)"
                
                // Add target-actions to all buttons inside the anime progress stack view
                for arrangedSubview in cell.animeProgressStackView.arrangedSubviews {
                    if let button = arrangedSubview as? UIButton {
                        button.addTarget(self, action: #selector(listValueChanged), for: [.touchUpInside])
                    }
                }
            } else if let mangaSeries = series as? MangaSeries {
                cell.maximumNumberOfVolumesLabel.text = "\(mangaSeries.numberOfTotalVolumes)"
                cell.maximumNumberOfChaptersLabel.text = "\(mangaSeries.numberOfTotalChapters)"
                
                // Add target-actions to all buttons inside the manga progress stack views
                for arrangedSubview in cell.chaptersReadStackView.arrangedSubviews {
                    if let button = arrangedSubview as? UIButton {
                        button.addTarget(self, action: #selector(listValueChanged), for: [.touchUpInside])
                    }
                }
                
                for arrangedSubview in cell.volumesReadStackView.arrangedSubviews {
                    if let button = arrangedSubview as? UIButton {
                        button.addTarget(self, action: #selector(listValueChanged), for: [.touchUpInside])
                    }
                }
            }
            
            return cell
        case .genres:
            // MARK: - Genre Cell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "genreCell") as! GenreTableViewCell
            cell.backgroundColor = Style.Color.Background.tableViewCell
            
            // Check if there are genres available
            guard series.genres.count > 0 else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            /*
                Iterate over all of the series' genres, create a label
                for each genre, set its text and add the label to the
                cell's genre label stack view
             */
            for genre in series.genres {
                let genreLabel = GenreLabel()
                genreLabel.text = genre
                cell.genreLabelStackView.addArrangedSubview(genreLabel)
            }
            
            return cell
        case .description:
            // MARK: - Description Cell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell") as! DescriptionTableViewCell
            
            // Check if the series has a description
            guard let description = series.description else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            /*
                Remove all <br> HTML tags from the description and set
                the description text view's text
             */
            let cleanDescription = description.replacingOccurrences(of: "<br>", with: "")
            
            cell.descriptionTextView.text = cleanDescription
            
            return cell
        case .characters:
            // MARK: - Character Images Cell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "characterImagesCell") as! ImagesTableViewCell
            cell.backgroundColor = Style.Color.Background.imagesTableViewCell
            
            // Check if there are available characters for the series
            guard let characters = series.characters,
                characters.count > 0 else {
                    return UITableViewCell(frame: CGRect.zero)
            }
            
            // Register the images collection view cell's nib file
            cell.imagesCollectionView.register(UINib(nibName: "ImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "imagesCollectionViewCell")
            
            // Configure the images collection view's flow layout and set the cell's type
            cell.imagesCollectionViewFlowLayout.itemSize = CGSize(width: (view.bounds.width / 3.5) > 100 ? 100 : (view.bounds.width / 3.5), height: (view.bounds.width / 3.5) > 100 ? 100 : (view.bounds.width / 3.5))
            cell.imagesCollectionViewFlowLayout.minimumLineSpacing = 1
            cell.type = ImagesTableViewCellType.characters
            
            /*
                Assign the series detail view controller as the images collection view's
                data source and delegate
             */
            cell.imagesCollectionView.dataSource = self
            cell.imagesCollectionView.delegate = self
            
            cell.imagesCollectionView.reloadData()
            
            return cell
        case .relations:
            // MARK: - Relations Images Cell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "relationImagesCell") as! ImagesTableViewCell
            cell.backgroundColor = Style.Color.Background.imagesTableViewCell
            
            // Check if there are available relations for the series
            guard let allRelations = series.allRelations,
                allRelations.count > 0 else {
                    return UITableViewCell(frame: CGRect.zero)
            }
            
            cell.titleLabel.text = "Relations"
            
            // Register the images collection view cell's nib file
            cell.imagesCollectionView.register(UINib(nibName: "ImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "imagesCollectionViewCell")
            
            // Configure the images collection view's flow layout and set the cell's type
            cell.imagesCollectionViewFlowLayout.itemSize = CGSize(width: (view.bounds.width / 3.5) > 100 ? 100 : (view.bounds.width / 3.5), height: (view.bounds.width / 3.5) > 100 ? 100 : (view.bounds.width / 3.5))
            cell.imagesCollectionViewFlowLayout.minimumLineSpacing = 1
            cell.type = ImagesTableViewCellType.relations
            
            /*
                Assign the series detail view controller as the images collection view's
                data source and delegate
             */
            cell.imagesCollectionView.dataSource = self
            cell.imagesCollectionView.delegate = self
            
            cell.imagesCollectionView.reloadData()
            
            return cell
        case .additionalInformations:
            // MARK: - Additional Informations Cell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "additionalInformationsCell") as! AdditionalInformationsTableViewCell
            cell.backgroundColor = Style.Color.Background.tableViewCell
            
            /*
                If the series type is anime and a studio is available,
                set the cell's studio value label's text
             */
            if series.seriesType == .anime,
                let series = series as? AnimeSeries,
                let studios = series.studios {
                var studioString = ""
                for studio in studios {
                    if studioString == "" {
                        studioString = "\(studio.name)"
                    } else {
                        studioString = "\(studioString), \(studio.name)"
                    }
                }
                cell.studioValueLabel.text = studioString
            }
            
            // Set the title value labels
            cell.englishTitleValueLabel.text = series.titleEnglish
            cell.romajiTitleValueLabel.text = series.titleRomaji
            cell.japaneseTitleValueLabel.text = series.titleJapanese
            
            // Set the synonyms value label if synonyms are available for the series
            if series.synonyms.count > 0 {
                var synonymValueText = ""
                for synonym in series.synonyms {
                    synonymValueText = synonymValueText == "" ? synonym : "\(synonymValueText), \(synonym)"
                }
                cell.synonymsValueLabel.text = synonymValueText
            } else {
                cell.synonymsValueLabel.text = "n/a"
            }
            
            return cell
        case .tags:
            // MARK: - Tags Cell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "tagsCell") as! GenreTableViewCell
            cell.backgroundColor = Style.Color.Background.tableViewCell
            
            // Check if the series has tags
            guard let tags = series.tags,
                tags.count > 0 else {
                    return UITableViewCell(frame: CGRect.zero)
            }
            
            /*
                Set the cell's title label as a genre table view cell is used for
                tags and the default value for its title is "Genres"
             */
            cell.titleLabel.text = "Tags"
            
            /*
                Iterate over all tags, create a genre label for each tag and
                set its text to the tag's name and add add the label to the
                cell's genre label stack view
             */
            for tag in tags {
                /*
                    Only create and add a tag if either the option to show tags with
                    spoilers is activated or if it doesn't contain spoilers
                 */
                if UserDefaults.standard.bool(forKey: "showTagsWithSpoilers") || (!UserDefaults.standard.bool(forKey: "showTagsWithSpoilers") && !tag.isSpoiler) {
                    let tagLabel = GenreLabel()
                    tagLabel.text = tag.name
                    cell.genreLabelStackView.addArrangedSubview(tagLabel)
                }
            }
            
            return cell
        case .externalLinks:
            // MARK: - External Links Cell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "externalLinksCell") as! ExternalLinksTableViewCell
            cell.backgroundColor = Style.Color.Background.tableViewCell
            
            /*
                Make sure the series can be casted to the AnimeSeries type
                because only anime series have external links available
             */
            guard let animeSeries = series as? AnimeSeries else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            // Check if the anime series has external links
            guard let externalLinks = animeSeries.externalLinks,
                externalLinks.count > 0 else {
                    return UITableViewCell(frame: CGRect.zero)
            }
            
            /*
                Assign the external links to the cell's externalLinks
                property and setup the cell
             */
            cell.externalLinks = externalLinks
            
            cell.setupCell()
            
            return cell

        case .video:
            // MARK: - Video Cell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell") as! VideoTableViewCell
            cell.backgroundColor = Style.Color.Background.tableViewCell
            
            /*
                Make sure the series type is anime and that the series can be casted
                to the AnimeSeries type as only anime have a YouTube video ID
             */
            guard series.seriesType == .anime,
                let animeSeries = series as? AnimeSeries else {
                    return UITableViewCell(frame: CGRect.zero)
            }
            
            /*
                Check if the anime has a YouTube video ID and try creating an URL
                for an embedded YouTube video with it
             */
            guard let youtubeVideoId = animeSeries.youtubeVideoId else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            guard let url = URL(string: "https://www.youtube.com/embed/\(youtubeVideoId)") else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            // Create a request from the URL and load it with the cell's video web view
            let request = URLRequest(url: url)
            cell.videoWebView.load(request)
            
            return cell
        }
    }
    
    /*
        This function should get called when a list value (e.g. progress for a series,
        rating, list status) changes.
     
        The function then tries to get all list values from the UI elements that contain
        them. After that, it calls the shared AniListClient's submitList method which puts
        list informations for a series to the server and passes it all the list values.
     */
    func listValueChanged() {
        // Try to get the actions cell from the series data table view
        if let actionsCell = seriesDataTableView.cellForRow(at: IndexPath(item: 1, section: 0)) as? ActionsTableViewCell {
            // Create constants for all list values
            let listStatus = actionsCell.userListStatusButton.title(for: .normal)!.lowercased()
            
            let watchedEpisodes: Int
            let readChapters: Int
            let readVolumes: Int
            let userScore: Int
            
            // Try to get the list values from the corresponding UI element
            if let watchedEpisodesText = actionsCell.watchedEpisodesTextField.text,
                let watchedEpisodesNumber = Int(watchedEpisodesText) {
                watchedEpisodes = watchedEpisodesNumber
            } else {
                watchedEpisodes = 0
            }
            
            if let readChaptersText = actionsCell.chaptersReadTextField.text,
                let readChaptersNumber = Int(readChaptersText) {
                readChapters = readChaptersNumber
            } else {
                readChapters = 0
            }
            
            if let readVolumesText = actionsCell.volumesReadTextField.text,
                let readVolumesNumber = Int(readVolumesText) {
                readVolumes = readVolumesNumber
            } else {
                readVolumes = 0
            }
            
            if let rateButtonUserScore = actionsCell.getUserScoreFromRateButton() {
                userScore = rateButtonUserScore
            } else {
                userScore = 0
            }
            
            NetworkActivityManager.shared.increaseNumberOfActiveConnections()
            
            // Submit the list
            AniListClient.shared.submitList(ofType: seriesType, withHttpMethod: "PUT", seriesId: seriesId, listStatusString: listStatus, userScore: userScore, episodesWatched: watchedEpisodes, readChapters: readChapters, readVolumes: readVolumes) { (errorMessage) in
                
                // Error Handling
                guard errorMessage == nil else {
                    self.errorMessageView.showAndHide(withMessage: errorMessage!)
                    NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                    return
                }
                
                /*
                    If there was no error, the submission was successful,
                    so make sure, that the cell is set up so it indicates
                    that it's in a list and that values can be changed
                */
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                DispatchQueue.main.async {
                    if let grantType = self.grantType {
                        actionsCell.setupCell(forGrantType: grantType, seriesType: self.seriesType, isSeriesInList: true)
                    }
                }
                
            }
        }
    }
}
