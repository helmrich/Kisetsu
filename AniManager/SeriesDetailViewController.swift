//
//  SeriesDetailViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 29.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class SeriesDetailViewController: UIViewController {

    // MARK: - Properties
    
    let errorMessageView = ErrorMessageView()
    
    var seriesId: Int!
    var seriesTitle: String!
    var seriesType: SeriesType! = .manga
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var seriesDataTableView: UITableView!
    
    
    // MARK: - Actions
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addErrorMessageView(toBottomOf: view, errorMessageView: errorMessageView)
        
        /*
            Get a single series object for the specified series ID and series type
            when the view controller is loaded
        */
 
        AniListClient.shared.getSingleSeries(ofType: seriesType, withId: seriesId) { (series, errorMessage) in
            guard errorMessage == nil else {
                self.errorMessageView.showError(withMessage: errorMessage!)
                return
            }
            
            guard let series = series else {
                self.errorMessageView.showError(withMessage: "Couldn't get series information")
                return
            }
            
            DispatchQueue.main.async {
                self.seriesDataTableView.reloadData()
            }
            
            // MARK: - Banner View Setup
            
            // Set the release year label
            if let seasonId = series.seasonId,
                let releaseYear = self.getReleaseYear(fromSeasonId: seasonId) {
                DispatchQueue.main.async {
                    (self.seriesDataTableView.tableHeaderView as! BannerView).seriesReleaseYearLabel.text = "\(releaseYear)"
                }
            }
            
            // Set the favourite button
            if let isFavorite = series.favorite,
                isFavorite {
                DispatchQueue.main.async {
                    (self.seriesDataTableView.tableHeaderView as! BannerView).favoriteButton.setImage(#imageLiteral(resourceName: "HeartIconActive"), for: .normal)
                }
            }
            
            guard let imageBannerUrlString = series.imageBannerUrlString else {
                return
            }
            
            AniListClient.shared.getImageData(fromUrlString: imageBannerUrlString) { (data, errorMessage) in
                guard errorMessage == nil else {
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                // Set the banner view image
                let bannerImage = UIImage(data: data)
                DispatchQueue.main.async {
                    (self.seriesDataTableView.tableHeaderView as! BannerView).imageView.image = bannerImage
                    UIView.animate(withDuration: 0.25) {
                        (self.seriesDataTableView.tableHeaderView as! BannerView).imageView.alpha = 1.0
                    }
                }
                
            }
            
        }
        
        seriesDataTableView.register(UINib(nibName: "ActionsTableViewCell", bundle: nil), forCellReuseIdentifier: "actionsCell")
        seriesDataTableView.register(UINib(nibName: "ImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "imagesCell")
        
        let bannerView = BannerView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 200))
        bannerView.dismissButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        bannerView.favoriteButton.addTarget(self, action: #selector(favorite), for: .touchUpInside)
        bannerView.seriesTitleLabel.text = seriesTitle
        
        seriesDataTableView.tableHeaderView = bannerView
        
        seriesDataTableView.estimatedRowHeight = 300
        seriesDataTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - Functions
    
    func goBack() {
        dismiss(animated: true, completion: nil)
    }
    
    func favorite() {
        AniListClient.shared.favorite(seriesOfType: seriesType, withId: seriesId) { (errorMessage) in
            guard errorMessage == nil else {
                self.errorMessageView.showError(withMessage: errorMessage!)
                return
            }
            
            /*
                Check whether the series was favorited or not based on the banner view
                based on the current image and toggle the image (if the image indicates
                that the series is a favorite (filled heart icon) it means that it was
                unfavorited, thus the heart icon should be empty and the other way around)
            */
            DispatchQueue.main.async {
                if (self.seriesDataTableView.tableHeaderView as! BannerView).favoriteButton.image(for: .normal) == #imageLiteral(resourceName: "HeartIconActive") {
                    (self.seriesDataTableView.tableHeaderView as! BannerView).favoriteButton.setImage(#imageLiteral(resourceName: "HeartIcon"), for: .normal)
                } else {
                    (self.seriesDataTableView.tableHeaderView as! BannerView).favoriteButton.setImage(#imageLiteral(resourceName: "HeartIconActive"), for: .normal)
                }
            }
            
        }
    }
    
    
    // MARK: - Helper Methods
    
    func createSeasonString(fromSeasonId seasonId: Int?) -> String? {
        
        guard let seasonId = seasonId else {
            return nil
        }
        
        /*
            The season ID is a 3-digit number where the first two
            numbers are the last two numbers of the season's year
            and the last number is the season (3 = summer, 4 = fall,
            1 = winter, 2 = spring)
         */
        let seasonIdString = "\(seasonId)"
        let yearPart = seasonIdString.substring(to: seasonIdString.index(before: seasonIdString.endIndex))
        let seasonNumber = seasonId % 10
        
        /*
            Because the API just returns two digits for the year and
            the database currently has series since 1951 it has to be
            assumed for now that if the season ID is larger than 504
            the series was released in the 20th century whereas if it's
            smaller the series was released in the 21th century
         */
        let year = seasonId > 504 ? "19\(yearPart)" : "20\(yearPart)"
        guard let season = Season(withSeasonNumber: seasonNumber) else {
            return nil
        }
        
        return "\(season.rawValue.capitalized) \(year)"
    }
    
    func getReleaseYear(fromSeasonId seasonId: Int?) -> Int? {
        
        guard let seasonId = seasonId else {
            return nil
        }
        
        /*
         The season ID is a 3-digit number where the first two
         numbers are the last two numbers of the season's year
         and the last number is the season (3 = summer, 4 = fall,
         1 = winter, 2 = spring)
         */
        let seasonIdString = "\(seasonId)"
        let yearPart = seasonIdString.substring(to: seasonIdString.index(before: seasonIdString.endIndex))
        if yearPart == "" {
            return nil
        }
        
        /*
         Because the API just returns two digits for the year and
         the database currently has series since 1951 it has to be
         assumed for now that if the season ID is larger than 504
         the series was released in the 20th century whereas if it's
         smaller the series was released in the 21th century
         */
        let yearString = seasonId > 504 ? "19\(yearPart)" : "20\(yearPart)"
        
        return Int(yearString)
    }
    
}


// MARK: - Table View Data Source

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
            
            cell.setupCell(forSeriesType: .manga)
            
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
}


// MARK: - Table View Delegate

extension SeriesDetailViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bannerView = seriesDataTableView.tableHeaderView as! BannerView
        bannerView.scrollViewDidScroll(scrollView: scrollView)
    }
}
