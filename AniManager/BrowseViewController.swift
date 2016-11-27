//
//  BrowseViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 22.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class BrowseViewController: UIViewController {

    // MARK: - Properties
    
    let errorMessageView = ErrorMessageView()
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var seriesCollectionView: UICollectionView!
    @IBOutlet weak var seriesCollectionViewFlowLayout: UICollectionViewFlowLayout!
    
    
    // MARK: - Actions
    
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        seriesCollectionViewFlowLayout.itemSize = CGSize(width: view.bounds.width / 3 - 0.67, height: view.bounds.width / 3 - 0.67)
        seriesCollectionViewFlowLayout.minimumInteritemSpacing = 1
        seriesCollectionViewFlowLayout.minimumLineSpacing = 1
        
        let parameters: [String:Any] = [
            AniListConstant.ParameterKey.Browse.year: "2015",
            AniListConstant.ParameterKey.Browse.genres: "Comedy,Romance",
            AniListConstant.ParameterKey.Browse.sort: "score-desc",
            AniListConstant.ParameterKey.Browse.season: Season.fall.rawValue
        ]
        
        DataSource.shared.getBrowseSeriesList(ofType: .anime, withParameters: parameters) { errorMessage in
            guard errorMessage == nil else {
                self.errorMessageView.showError(withMessage: errorMessage!)
                return
            }
            
            DispatchQueue.main.async {
                self.seriesCollectionView.reloadData()
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.navigationItem.title = "Browse"
        // TODO: Add target-action
        tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "SettingBarsIcon"), style: .plain, target: nil, action: nil)
    }
    
    
    // MARK: - Functions
    
    
    
}

extension BrowseViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let browseSeriesList = DataSource.shared.browseSeriesList else {
            return 0
        }
        
        return browseSeriesList.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seriesCell", for: indexPath) as! SeriesCollectionViewCell
        
        guard let browseSeriesList = DataSource.shared.browseSeriesList else {
            return cell
        }
        
        let currentSeries = browseSeriesList[indexPath.row]

        if cell.seriesId == nil {
            cell.seriesId = currentSeries.id
        }
        
        if cell.imageView.image == nil {
            DataSource.shared.getImageData(forCellAtIndexPath: indexPath) { (image, errorMessage) in
                guard errorMessage == nil else {
                    self.errorMessageView.showError(withMessage: errorMessage!)
                    return
                }
                
                guard let image = image else {
                    self.errorMessageView.showError(withMessage: "Couldn't get image")
                    return
                }
                
                DispatchQueue.main.async {
                    cell.imageOverlay.isHidden = false
                    cell.titleLabel.text = currentSeries.titleEnglish
                    cell.titleLabel.isHidden = false
                    cell.imageView.image = image
                }
                
            }
        }
        
        return cell
        
    }
}

extension BrowseViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! SeriesCollectionViewCell
        print(selectedCell.seriesId)
        print(selectedCell.titleLabel.text)
    }
}
