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
    
    var seriesType: SeriesType?
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var seriesCollectionView: UICollectionView!
    
    
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
            if seriesType == .anime {
                status = AnimeListName(rawValue: self.title!)!.asKey()
            } else {
                status = MangaListName(rawValue: self.title!)!.asKey()
            }
            
            AniListClient.shared.getList(ofType: seriesType, withStatus: status, andUserId: user.id, andDisplayName: nil) { (seriesList, errorMessage) in
                guard errorMessage == nil else {
                    print(errorMessage!)
                    return
                }
                
                guard let seriesList = seriesList else {
                    print("Couldn't get series list")
                    return
                }
                
                guard let animeSeriesList = seriesList as? [AnimeSeries] else {
                    print("Couldn't cast series list to anime series list")
                    return
                }
                
                DataSource.shared.browseSeriesList = animeSeriesList
                DispatchQueue.main.async {
                    self.seriesCollectionView.reloadData()
                    UIView.animate(withDuration: 0.25) {
                        self.seriesCollectionView.alpha = 1.0
                    }
                }
                
            }
            
        }
        
    }

}
