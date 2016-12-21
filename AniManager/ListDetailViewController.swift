//
//  ListDetailViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 12.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class ListDetailViewController: SeriesCollectionViewController {

    // MARK: - Properties
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var seriesCollectionView: UICollectionView!
    @IBOutlet weak var seriesCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var nothingFoundLabel: UILabel!
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure(seriesCollectionViewFlowLayout)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        seriesCollectionView.alpha = 0.0
        
        AniListClient.shared.getAuthenticatedUser { (user, errorMessage) in
            guard errorMessage == nil else {
                print(errorMessage!)
                return
            }
            
            guard let user = user else {
                print("Couldn't get user")
                return
            }
            
            guard let seriesType = self.seriesType else {
                print("No valid series type given")
                return
            }
            
            let status: String
            let nothingFoundText: String
            if seriesType == .anime {
                status = AnimeListName(rawValue: self.title!)!.asKey()
                nothingFoundText = "No anime found"
            } else {
                status = MangaListName(rawValue: self.title!)!.asKey()
                nothingFoundText = "No manga found"
            }
            
            AniListClient.shared.getList(ofType: seriesType, withStatus: status, andUserId: user.id, andDisplayName: nil) { (seriesList, errorMessage) in
                
                DispatchQueue.main.async {
                    self.activityIndicatorView.startAnimating()
                    UIView.animate(withDuration: 0.25) {
                        self.activityIndicatorView.alpha = 1.0
                    }
                }
                
                guard errorMessage == nil else {
                    DispatchQueue.main.async {
                        self.nothingFoundLabel.text = nothingFoundText
                        self.activityIndicatorView.stopAnimating()
                        UIView.animate(withDuration: 0.25) {
                            self.nothingFoundLabel.alpha = 1.0
                            self.activityIndicatorView.alpha = 0.0
                        }
                    }
                    return
                }
                
                guard let generalSeriesList = seriesList else {
                    print("Couldn't get series list")
                    return
                }
                
                if seriesType == .anime,
                    let animeSeriesList = generalSeriesList as? [AnimeSeries] {
                    DataSource.shared.selectedAnimeList = animeSeriesList
                } else if seriesType == .manga,
                    let mangaSeriesList = generalSeriesList as? [MangaSeries] {
                    DataSource.shared.selectedMangaList = mangaSeriesList
                } else {
                    print("Couldn't create manga/anime series list from general series list")
                    return
                }
                
                DispatchQueue.main.async {
                    self.seriesCollectionView.reloadData()
                    self.activityIndicatorView.stopAnimating()
                    UIView.animate(withDuration: 0.25) {
                        self.activityIndicatorView.alpha = 0.0
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
        
        let currentSeries: Series
        /*
            Check the view controller's series type and get the appropriate
            list from the data source
         */
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
