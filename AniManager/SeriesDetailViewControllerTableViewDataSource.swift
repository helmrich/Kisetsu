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
        return 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicInformationsCell") as! BasicInformationsTableViewCell
            
            guard let series = DataSource.shared.selectedSeries else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            AniListClient.shared.getImageData(fromUrlString: series.imageLargeUrlString) { (imageData, errorMessage) in
                guard errorMessage == nil else {
                    self.errorMessageView.showError(withMessage: errorMessage!)
                    return
                }
                
                guard let imageData = imageData else {
                    self.errorMessageView.showError(withMessage: "Couldn't get image")
                    return
                }
                
                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    cell.seriesCoverImageView.image = image
                    UIView.animate(withDuration: 0.25) {
                        cell.seriesCoverImageView.alpha = 1.0
                    }
                }
                
            }
            
            // Set cell property values that both series types have
            cell.averageRatingValueLabel.text = "\(Int(round(series.averageScore)))"
            
            // Set the cell's average rating value label's color depending on
            // the score
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
                cell.toggleAnimeSpecificLabels(hidden: false)
                cell.statusValueLabel.text = animeSeries.airingStatus != nil ? animeSeries.airingStatus!.rawValue : "n/a"
                cell.durationPerEpisodeValueLabel.text = animeSeries.durationPerEpisode != nil ? "\(animeSeries.durationPerEpisode!)min" : "n/a"
                cell.numberOfEpisodesValueLabel.text = "\(animeSeries.numberOfTotalEpisodes)"
                let seasonString = createSeasonString(fromSeasonId: animeSeries.seasonId)
                cell.seasonValueLabel.text = seasonString != nil ? seasonString : "n/a"
                // layoutSubviews has to be called so that the the cell's labels
                // with dynamic content will update their width based on the values
                cell.layoutSubviews()
                return cell
            case .manga:
                let mangaSeries = series as! MangaSeries
                cell.statusValueLabel.text = mangaSeries.publishingStatus?.rawValue
                // TODO: Add more manga-specific values
                cell.toggleAnimeSpecificLabels(hidden: true)
                // layoutSubviews has to be called so that the the cell's labels
                // with dynamic content will update their width based on the values
                cell.layoutSubviews()
                return cell
            }
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "actionsCell") as! ActionsTableViewCell
            
            guard let series = DataSource.shared.selectedSeries else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            cell.setupCell(forSeriesType: seriesType)
            
            AniListClient.shared.getAuthenticatedUser { (user, errorMessage) in
                guard errorMessage == nil else {
                    self.errorMessageView.showError(withMessage: errorMessage!)
                    return
                }
                
                guard let user = user else {
                    self.errorMessageView.showError(withMessage: "Couldn't get authenticated user")
                    return
                }
                
                AniListClient.shared.getListInformations(forSeriesOfType: self.seriesType, withId: self.seriesId, forUserId: user.id, forDisplayName: nil) { (status, userScore, episodesWatched, readChapters, readVolumes, errorMessage) in
                    
                    guard errorMessage == nil else {
                        print(errorMessage!)
                        DispatchQueue.main.async {
                            cell.setupCellForStatus(isSeriesInList: false)
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        
                        cell.setupCellForStatus(isSeriesInList: true)
                        
                        if let status = status {
                            cell.userListStatusButton.setTitle(status.capitalized, for: .normal)
                        }
                        
                        if let userScore = userScore {
                            cell.rateButton.setTitle("Your Rating: \(userScore)", for: .normal)
                        }
                        
                        if self.seriesType == .anime {
                            if let episodesWatched = episodesWatched {
                                cell.watchedEpisodesTextField.text = "\(episodesWatched)"
                                print("Episodes watched: \(episodesWatched)")
                            }
                        } else if self.seriesType == .manga {
                            if let readChapters = readChapters {
                                cell.chaptersReadTextField.text = "\(readChapters)"
                            }
                            
                            if let readVolumes = readVolumes {
                                cell.volumesReadTextField.text = "\(readVolumes)"
                            }
                        }
                    }
                }
            }
            
            cell.userListStatusButton.addTarget(self, action: #selector(showLists), for: [.touchUpInside])
            
            if let animeSeries = series as? AnimeSeries {
                print("Setting number of episodes...")
                cell.maximumNumberOfEpisodesLabel.text = "\(animeSeries.numberOfTotalEpisodes)"
                
                // Add target-actions to all buttons inside the anime progress stack view
                for arrangedSubview in cell.animeProgressStackView.arrangedSubviews {
                    if let button = arrangedSubview as? UIButton {
                        button.addTarget(self, action: #selector(listValueChanged), for: [.touchUpInside])
                    }
                }
            } else if let mangaSeries = series as? MangaSeries {
                print("Setting number of volumes and chapters...")
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
            
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "genreCell") as! GenreTableViewCell
            
            guard let series = DataSource.shared.selectedSeries else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            guard series.genres.count > 0 else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            guard cell.genreLabelStackView.arrangedSubviews.count != series.genres.count else {
                return cell
            }
            
            for genre in series.genres {
                let genreLabel = GenreLabel()
                genreLabel.text = genre
                cell.genreLabelStackView.addArrangedSubview(genreLabel)
            }
            
            return cell
            
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell") as! DescriptionTableViewCell
            
            guard let series = DataSource.shared.selectedSeries else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            guard let description = series.description else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            let cleanDescription = description.replacingOccurrences(of: "<br>", with: "")
            
            cell.descriptionTextView.text = cleanDescription
            
            return cell
        } else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imagesCell") as! ImagesTableViewCell
            
            guard let series = DataSource.shared.selectedSeries else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            guard let characters = series.characters,
                characters.count > 0 else {
                    return UITableViewCell(frame: CGRect.zero)
            }
            
            cell.imagesCollectionView.register(UINib(nibName: "ImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "imagesCollectionViewCell")
            
            cell.imagesCollectionViewFlowLayout.itemSize = CGSize(width: (view.bounds.width / 3.5) > 100 ? 100 : (view.bounds.width / 3.5), height: (view.bounds.width / 3.5) > 100 ? 100 : (view.bounds.width / 3.5))
            cell.imagesCollectionViewFlowLayout.minimumLineSpacing = 1
            cell.type = ImagesTableViewCellType.characters
            
            cell.imagesCollectionView.dataSource = self
            cell.imagesCollectionView.delegate = self
            
            
            
            return cell
        } else if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "additionalInformationsCell") as! AdditionalInformationsTableViewCell
            
            guard let series = DataSource.shared.selectedSeries else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
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
            
            cell.englishTitleValueLabel.text = series.titleEnglish
            cell.romajiTitleValueLabel.text = series.titleRomaji
            cell.japaneseTitleValueLabel.text = series.titleJapanese
            
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
        } else if indexPath.row == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tagsCell") as! GenreTableViewCell
            
            guard let series = DataSource.shared.selectedSeries else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            guard let tags = series.tags else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            cell.titleLabel.text = "Tags"
            
            guard cell.genreLabelStackView.arrangedSubviews.count != tags.count else {
                return cell
            }
            
            for tag in tags {
                let genreLabel = GenreLabel()
                genreLabel.text = tag.name
                cell.genreLabelStackView.addArrangedSubview(genreLabel)
            }
            
            return cell
            
        } else if indexPath.row == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "externalLinksCell") as! ExternalLinksTableViewCell
            
            guard let series = DataSource.shared.selectedSeries else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            guard let animeSeries = series as? AnimeSeries else {
                print("Anime Series error")
                return UITableViewCell(frame: CGRect.zero)
            }
            
            guard let externalLinks = animeSeries.externalLinks else {
                print("No external links available")
                return UITableViewCell(frame: CGRect.zero)
            }
            
            print(externalLinks)
            
            cell.externalLinks = externalLinks
            
            cell.setupCell()
            
            return cell
        } else if indexPath.row == 8 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell") as! VideoTableViewCell
            
            guard let series = DataSource.shared.selectedSeries else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            guard series.seriesType == .anime else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            guard let youtubeVideoId = (series as! AnimeSeries).youtubeVideoId else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            guard let url = URL(string: "https://www.youtube.com/embed/\(youtubeVideoId)") else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            let request = URLRequest(url: url)
            
            cell.videoWebView.load(request)
            
            return cell
        } else {
            return UITableViewCell(frame: CGRect.zero)
        }
    }
    
    func listValueChanged() {
        if let actionsCell = seriesDataTableView.cellForRow(at: IndexPath(item: 1, section: 0)) as? ActionsTableViewCell {
            
            let httpMethod = "PUT"
            let listStatus = actionsCell.userListStatusButton.title(for: .normal)!.lowercased()
            
            let watchedEpisodes: Int
            let readChapters: Int
            let readVolumes: Int
            let userScore: Int
                
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
            
            AniListClient.shared.submitList(ofType: seriesType, withHttpMethod: httpMethod, seriesId: seriesId, listStatusString: listStatus, userScore: userScore, episodesWatched: watchedEpisodes, readChapters: readChapters, readVolumes: readVolumes) { (errorMessage) in
                guard errorMessage == nil else {
                    print("ERROR: \(errorMessage!)")
                    return
                }
                
                /*
                    If there was no error, the submission was successful,
                    so make sure, that the cell is set up so it indicates
                    that it's in a list and that values can be changed
                */
                DispatchQueue.main.async {
                    actionsCell.setupCellForStatus(isSeriesInList: true)
                }
                
            }
        }
    }
    
}
