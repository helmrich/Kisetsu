//
//  ListDetailViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 12.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class ListDetailViewController: SeriesCollectionViewController {
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var seriesCollectionView: UICollectionView!
    @IBOutlet weak var seriesCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var nothingFoundLabel: UILabel!
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the series collection view's flow layout
        configure(seriesCollectionViewFlowLayout)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the series collection view initially
        seriesCollectionView.alpha = 0.0
        
        AniListClient.shared.getAuthenticatedUser { (user, errorMessage) in
            
            // Error Handling
            guard errorMessage == nil else {
                self.errorMessageView.showError(withMessage: errorMessage!)
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                    UIView.animate(withDuration: 0.25) {
                        self.activityIndicatorView.alpha = 0.0
                    }
                }
                return
            }
            
            guard let user = user else {
                self.errorMessageView.showError(withMessage: "Couldn't get user")
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                    UIView.animate(withDuration: 0.25) {
                        self.activityIndicatorView.alpha = 0.0
                    }
                }
                return
            }
            
            guard let seriesType = self.seriesType else {
                self.errorMessageView.showError(withMessage: "No valid series type given")
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                    UIView.animate(withDuration: 0.25) {
                        self.activityIndicatorView.alpha = 0.0
                    }
                }
                return
            }
            
            /*
                Get the appropriate status key for the request by getting
                the current view controller's title and initializing an
                Anime/MangaListName object with it as a raw value and calling
                the asKey method on it
             */
            let status: String
            if seriesType == .anime {
                status = AnimeListName(rawValue: self.title!)!.asKey()
            } else if seriesType == .manga {
                status = MangaListName(rawValue: self.title!)!.asKey()
            } else {
                self.errorMessageView.showError(withMessage: "Invalid series type")
                return
            }
            
            // Show the activity indicator
            self.activityIndicatorView.startAnimatingAndFadeIn()
            
            // Request a series list
            AniListClient.shared.getList(ofType: seriesType, withStatus: status, andUserId: user.id, andDisplayName: nil) { (seriesList, errorMessage) in
                
                // Error Handling
                guard errorMessage == nil else {
                    DispatchQueue.main.async {
                        self.nothingFoundLabel.text = "No \(self.seriesType.rawValue) found"
                        UIView.animate(withDuration: 0.25) {
                            self.nothingFoundLabel.alpha = 1.0
                        }
                    }
                    self.activityIndicatorView.stopAnimatingAndFadeOut()
                    return
                }
                
                guard let generalSeriesList = seriesList else {
                    self.errorMessageView.showError(withMessage: "Couldn't get series list")
                    self.activityIndicatorView.stopAnimatingAndFadeOut()
                    return
                }
                
                /*
                    Check the series type and cast the general series list to
                    the appropriate type. Then assign the casted list to the
                    appropriate property in the shared data source
                 */
                if seriesType == .anime,
                    let animeSeriesList = generalSeriesList as? [AnimeSeries] {
                    DataSource.shared.selectedAnimeList = animeSeriesList
                } else if seriesType == .manga,
                    let mangaSeriesList = generalSeriesList as? [MangaSeries] {
                    DataSource.shared.selectedMangaList = mangaSeriesList
                } else {
                    self.errorMessageView.showError(withMessage: "Couldn't create \(self.seriesType.rawValue) list")
                    self.activityIndicatorView.stopAnimatingAndFadeOut()
                    return
                }
                
                /*
                    Reload and show the collection view, stop the activity
                    indicator's animation and hide it and the "nothing found"-
                    label
                 */
                self.activityIndicatorView.stopAnimatingAndFadeOut()
                DispatchQueue.main.async {
                    self.seriesCollectionView.reloadData()
                    UIView.animate(withDuration: 0.25) {
                        self.nothingFoundLabel.alpha = 0.0
                        self.seriesCollectionView.alpha = 1.0
                    }
                }
            }
        }
    }
}

extension ListDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /*
            Check the series type and set the number of items in the section
            to the number of items in the belonging selected list in the shared
            data source
         */
        if seriesType == .anime,
            let selectedAnimeList = DataSource.shared.selectedAnimeList {
            return selectedAnimeList.count
        } else if seriesType == .manga,
            let selectedMangaList = DataSource.shared.selectedMangaList {
            return selectedMangaList.count
        } else {
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seriesCell", for: indexPath) as! SeriesCollectionViewCell
        
        /*
         Check the view controller's series type and get the appropriate
         list from the data source. Then set the current cell's progress label,
         title label and series ID to the values of the series at the index in
         the selected series list that's equal to the current index path's row
         value and download the series' image
         */
        let currentSeries: Series
        if seriesType == .anime,
            let selectedAnimeList = DataSource.shared.selectedAnimeList {
            // If the
            if let watchedEpisodes = selectedAnimeList[indexPath.row].watchedEpisodes {
                cell.progressLabel.text = "\(watchedEpisodes)/\(selectedAnimeList[indexPath.row].numberOfTotalEpisodes)"
                cell.progressLabel.isHidden = false
            }
            seriesType = .anime
            currentSeries = selectedAnimeList[indexPath.row]
        } else if seriesType == .manga,
            let selectedMangaList = DataSource.shared.selectedMangaList {
            if let readChapters = selectedMangaList[indexPath.row].readChapters {
                cell.progressLabel.text = "Ch. \(readChapters)/\(selectedMangaList[indexPath.row].numberOfTotalChapters)"
                cell.progressLabel.isHidden = false
            } else if let readVolumes = selectedMangaList[indexPath.row].readVolumes {
                cell.progressLabel.text = "Vol. \(readVolumes)/\(selectedMangaList[indexPath.row].numberOfTotalVolumes)"
                cell.progressLabel.isHidden = false
            }
            seriesType = .manga
            currentSeries = selectedMangaList[indexPath.row]
        } else {
            return cell
        }
        
        if cell.seriesId == nil {
            cell.seriesId = currentSeries.id
        }
        
        if cell.imageView.image == nil {
            AniListClient.shared.getImageData(fromUrlString: currentSeries.imageMediumUrlString) { (imageData, errorMessage) in
                guard errorMessage == nil else {
                    return
                }
                
                guard let imageData = imageData else {
                    return
                }
                
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        cell.imageOverlay.isHidden = false
                        cell.titleLabel.text = currentSeries.titleEnglish
                        cell.titleLabel.isHidden = false
                        cell.imageView.image = image
                    }
                }
            }
        }
        
        return cell
        
    }
}
