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
        
        // Add observer for the "settingValueChanged" notification
        NotificationCenter.default.addObserver(self, selector: #selector(settingValueChanged), name: Notification.Name(rawValue: Constant.NotificationKey.settingValueChanged), object: nil)
        
        // Configure the series collection view's flow layout
        configure(seriesCollectionViewFlowLayout)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NetworkActivityManager.shared.numberOfActiveConnections = 0
        
        // Hide the series collection view initially
        seriesCollectionView.alpha = 0.0
        
        NetworkActivityManager.shared.increaseNumberOfActiveConnections()
        
        AniListClient.shared.getAuthenticatedUser { (user, errorMessage) in
            
            // Error Handling
            guard errorMessage == nil else {
                self.errorMessageView.showAndHide(withMessage: errorMessage!)
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                    UIView.animate(withDuration: 0.25) {
                        self.activityIndicatorView.alpha = 0.0
                    }
                }
                return
            }
            
            guard let user = user else {
                self.errorMessageView.showAndHide(withMessage: "Couldn't get user")
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                    UIView.animate(withDuration: 0.25) {
                        self.activityIndicatorView.alpha = 0.0
                    }
                }
                return
            }
            
            guard let seriesType = self.seriesType else {
                self.errorMessageView.showAndHide(withMessage: "No valid series type given")
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
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
                self.errorMessageView.showAndHide(withMessage: "Invalid series type")
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                return
            }
            
            // Show the activity indicator
            self.activityIndicatorView.startAnimatingAndFadeIn()
            
            // Request a series list
            AniListClient.shared.getList(ofType: seriesType, withStatus: status, userId: user.id, andDisplayName: nil) { (seriesList, errorMessage) in
                
                // Error Handling
                guard errorMessage == nil else {
                    NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
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
                    self.errorMessageView.showAndHide(withMessage: "Couldn't get series list")
                    self.activityIndicatorView.stopAnimatingAndFadeOut()
                    NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
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
                    self.errorMessageView.showAndHide(withMessage: "Couldn't create \(self.seriesType.rawValue) list")
                    self.activityIndicatorView.stopAnimatingAndFadeOut()
                    NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                    return
                }
                
                /*
                    Reload and show the collection view, stop the activity
                    indicator's animation and hide it and the "nothing found"-
                    label
                 */
                self.activityIndicatorView.stopAnimatingAndFadeOut()
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
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
    
    // MARK: - Functions
    
    func settingValueChanged() {
        seriesCollectionView.reloadData()
    }
}

// MARK: - Collection View Data Source

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
        
        cell.titleLabel.text = currentSeries.titleForSelectedTitleLanguageSetting
        cell.titleLabel.alpha = 1.0
        cell.imageOverlay.alpha = 0.7
        
        if cell.imageView.image == nil,
            let imageMediumUrl = URL(string: currentSeries.imageMediumUrlString) {
            cell.imageView.kf.setImage(with: imageMediumUrl, placeholder: UIImage.with(color: .aniManagerGray, andSize: cell.imageView.bounds.size), options: [.transition(.fade(0.25))], progressBlock: nil, completionHandler: nil)
        }
        
        return cell
        
    }
}
