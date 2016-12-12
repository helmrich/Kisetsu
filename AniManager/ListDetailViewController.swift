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
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var nothingFoundLabel: UILabel!
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                
                let seriesList: [Series]
                if seriesType == .anime,
                    let animeSeriesList = generalSeriesList as? [AnimeSeries] {
                    seriesList = animeSeriesList
                } else if seriesType == .manga,
                    let mangaSeriesList = generalSeriesList as? [MangaSeries] {
                    seriesList = mangaSeriesList
                } else {
                    print("Couldn't create manga/anime series list from general series list")
                    return
                }
                
                DataSource.shared.browseSeriesList = seriesList
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
