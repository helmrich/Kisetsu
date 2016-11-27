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
    
    // TEMPORARY
    
    var seriesList: [Series]? = nil {
        didSet {
            DispatchQueue.main.async {
                self.seriesCollectionView.reloadData()
            }
        }
    }
    
    var images = [IndexPath:UIImage]()
    
    // TEMPORARY
    
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
            AniListConstant.ParameterKey.Browse.year: "2016",
//            AniListConstant.ParameterKey.Browse.genres: "Comedy",
            AniListConstant.ParameterKey.Browse.sort: "score-desc",
            AniListConstant.ParameterKey.Browse.season: Season.fall.rawValue
        ]
        
        AniListClient.shared.getSeriesList(ofType: .anime, andParameters: parameters) { (seriesList, errorMessage) in
            
            guard errorMessage == nil else {
                DispatchQueue.main.async {
                    self.errorMessageView.showError(withMessage: errorMessage!)
                }
                return
            }
            
            guard let seriesList = seriesList else {
                DispatchQueue.main.async {
                    self.errorMessageView.showError(withMessage: "Couldn't get series list")
                }
                return
            }
            
            self.seriesList = seriesList
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.navigationItem.title = "Browse"
        // TODO: Add target-action
        tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "SettingBarsIcon"), style: .plain, target: nil, action: nil)
    }
    
    
    // MARK: - Functions
    
    func getImageData(forCellAtIndexPath indexPath: IndexPath) {
        
        print("Inserting image at index path \(indexPath)...")
        
        guard let seriesList = seriesList else {
            return
        }
        let series = seriesList[indexPath.row]
        AniListClient.shared.getImageData(fromUrlString: series.imageMediumUrlString) { (imageData, errorMessage) in
            guard errorMessage == nil else {
                self.errorMessageView.showError(withMessage: errorMessage!)
                return
            }
            
            guard let imageData = imageData else {
                self.errorMessageView.showError(withMessage: "Couldn't get image data")
                return
            }
            
            if let image = UIImage(data: imageData) {
                self.images[indexPath] = image
                DispatchQueue.main.async {
                    self.seriesCollectionView.reloadItems(at: [indexPath])
                }
            }
            
        }
    }
    
}

extension BrowseViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let seriesList = seriesList else {
            return 0
        }
        
        return seriesList.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seriesCell", for: indexPath) as! SeriesCollectionViewCell
        
        guard let seriesList = seriesList else {
            return cell
        }
        
        let currentSeries = seriesList[indexPath.row]

        if let currentSeriesImage = images[indexPath] {
            cell.imageOverlay.isHidden = false
            cell.titleLabel.text = currentSeries.titleEnglish
            cell.titleLabel.isHidden = false
            cell.imageView.image = currentSeriesImage
        }
        
        if cell.imageView.image == nil {
            getImageData(forCellAtIndexPath: indexPath)
        }
        
        return cell
        
    }
}

extension BrowseViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: Implement
    }
}
