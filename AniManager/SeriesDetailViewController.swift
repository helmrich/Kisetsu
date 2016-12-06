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
    var seriesType: SeriesType!
    
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
        
        AniListClient.shared.getSingleSeries(ofType: .anime, withId: seriesId) { (series, errorMessage) in
            guard errorMessage == nil else {
                self.errorMessageView.showError(withMessage: errorMessage!)
                return
            }
            
            guard let series = series else {
                self.errorMessageView.showError(withMessage: "Couldn't get series information")
                return
            }
            
            dump(series)
            
            DispatchQueue.main.async {
                self.seriesDataTableView.reloadData()
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
                
                let bannerImage = UIImage(data: data)
                DispatchQueue.main.async {
                    (self.seriesDataTableView.tableHeaderView as! BannerView).imageView.image = bannerImage
                }
                
            }
            
        }
        
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
        print("Favoriting...")
    }
    
}


// MARK: - Table View Data Source

extension SeriesDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
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
                }
                
            }
            
            // Set cell property values that both series types have
            cell.averageRatingValueLabel.text = "\(series.averageScore)"
            cell.typeValueLabel.text = "TV"
            
            // Set specific property values depending on the series type
            
            switch series.seriesType {
            case .anime:
                let animeSeries = series as! AnimeSeries
                cell.statusValueLabel.text = animeSeries.airingStatus != nil ? animeSeries.airingStatus!.rawValue : "n/a"
                cell.durationPerEpisodeValueLabel.text = animeSeries.durationPerEpisode != nil ? "\(animeSeries.durationPerEpisode!)min" : "n/a"
                cell.numberOfEpisodesValueLabel.text = "\(animeSeries.numberOfTotalEpisodes)"
                cell.seasonValueLabel.text = animeSeries.seasonId != nil ? "\(animeSeries.seasonId!)" : "n/a"
                // layoutSubviews has to be called so that the the cell's labels
                // with dynamic content will update their width based on the values
                cell.layoutSubviews()
                return cell
            case .manga:
                let mangaSeries = series as! MangaSeries
                cell.statusValueLabel.text = mangaSeries.publishingStatus?.rawValue
                // TODO: Add more manga-specific values
                
                // layoutSubviews has to be called so that the the cell's labels
                // with dynamic content will update their width based on the values
                cell.layoutSubviews()
                return cell
            }
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "genreCell") as! GenreTableViewCell
            
            guard let series = DataSource.shared.selectedSeries else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            guard cell.genreLabelStackView.arrangedSubviews.count != series.genres.count else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            for genre in series.genres {
                let genreLabel = GenreLabel()
                genreLabel.text = genre
                cell.genreLabelStackView.addArrangedSubview(genreLabel)
            }
            
            return cell
        
        } else if indexPath.row == 2 {
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
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "additionalInformationsCell") as! AdditionalInformationsTableViewCell
            
            guard let series = DataSource.shared.selectedSeries else {
                return cell
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
        } else if indexPath.row == 4 {
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
        } else if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imagesCell") as! ImagesTableViewCell
            
            cell.imagesCollectionView.dataSource = self
            cell.imagesCollectionView.delegate = self
            cell.imagesCollectionView.register(UINib(nibName: "ImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "imagesCollectionViewCell")
            cell.imagesCollectionView.showsHorizontalScrollIndicator = false
            cell.imagesCollectionViewFlowLayout.itemSize = CGSize(width: view.bounds.width / 3.5, height: view.bounds.width / 3.5)
            cell.imagesCollectionViewFlowLayout.minimumLineSpacing = 1
            cell.type = ImagesTableViewCellType.characters
            
            guard let series = DataSource.shared.selectedSeries else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
            guard let characters = series.characters,
            characters.count > 0 else {
                return UITableViewCell(frame: CGRect.zero)
            }
            
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
