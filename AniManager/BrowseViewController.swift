//
//  BrowseViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 22.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class BrowseViewController: SeriesCollectionViewController {

    // MARK: - Properties
    
    let parameters: [String:Any] = [
        AniListConstant.ParameterKey.Browse.year: "2015",
        AniListConstant.ParameterKey.Browse.genres: "Comedy",
        AniListConstant.ParameterKey.Browse.sort: "score-desc",
//        AniListConstant.ParameterKey.Browse.season: Season.fall.rawValue
    ]
    var showsAllAvailableSeriesItems = false
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var seriesCollectionView: UICollectionView!
    @IBOutlet weak var seriesCollectionViewFlowLayout: UICollectionViewFlowLayout!
    
    // MARK: - Actions
    
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barStyle = .blackTranslucent
        
        seriesCollectionView.alpha = 0.0
        
        activityIndicatorView.startAnimating()
        UIView.animate(withDuration: 0.25) {
            self.activityIndicatorView.alpha = 1.0
        }
        
        addErrorMessageView(toBottomOf: view, withOffsetToBottom: 49.0, errorMessageView: errorMessageView)
        
        seriesCollectionViewFlowLayout.itemSize = CGSize(width: view.bounds.width / 3 - 0.67, height: view.bounds.width / 3 - 0.67)
        seriesCollectionViewFlowLayout.minimumInteritemSpacing = 1
        seriesCollectionViewFlowLayout.minimumLineSpacing = 1
        
        
        
        AniListClient.shared.getSeriesList(ofType: seriesType, andParameters: parameters) { (seriesList, errorMessage) in
            guard errorMessage == nil else {
                self.errorMessageView.showError(withMessage: errorMessage!)
                return
            }
            
            guard let seriesList = seriesList else {
                self.errorMessageView.showError(withMessage: "Couldn't get series list")
                return
            }
            
            DataSource.shared.browseSeriesList = seriesList
            
            DispatchQueue.main.async {
                self.seriesCollectionView.reloadData()
                self.activityIndicatorView.stopAnimating()
                UIView.animate(withDuration: 0.25) {
                    self.activityIndicatorView.alpha = 0.0
                    self.seriesCollectionView.alpha = 1.0
                }
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        statusBarShouldBeHidden = false
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    
    // MARK: - Functions
    
    @IBAction func openFilterModal() {
        let filterViewController = storyboard!.instantiateViewController(withIdentifier: "browseFilterViewController") as! BrowseFilterViewController
        filterViewController.modalPresentationStyle = .custom
        filterViewController.transitioningDelegate = self
        UIView.animate(withDuration: 0.5) {
            self.seriesCollectionView.alpha = 0.5
        }
        self.present(filterViewController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard DataSource.shared.browseSeriesList != nil else {
            return
        }
        
        /*
            Every time when a cell will be displayed it should be checked,
            if the displayed cell is the last cell of the collection view
            by comparing its row's index path (+ 1) to the number of series
            items in the browse series list. If it's the last cell,
            a new series list should be requested from the page that comes
            after the page the last series list was downloaded from
        */
        if indexPath.row + 1 == DataSource.shared.browseSeriesList!.count && !showsAllAvailableSeriesItems {
            
            /*
                Get the last cell's index paths so that new items can be inserted
                after it
            */
            let lastCellIndexPathItem = DataSource.shared.browseSeriesList!.count - 1
            
            AniListClient.shared.getSeriesList(fromPage: Int(DataSource.shared.browseSeriesList!.count / 40) + 1, ofType: seriesType, andParameters: parameters) { (seriesList, errorMessage) in
                guard errorMessage == nil else {
                    self.errorMessageView.showError(withMessage: errorMessage!)
                    return
                }

                guard let generalSeriesList = seriesList else {
                    self.errorMessageView.showError(withMessage: "Couldn't get series list")
                    return
                }
                
                if generalSeriesList.count < 40 {
                    self.showsAllAvailableSeriesItems = true
                }

                guard self.seriesType == .anime else {
                    if let mangaSeriesList = generalSeriesList as? [MangaSeries],
                        let currentMangaBrowseSeriesList = DataSource.shared.browseSeriesList as? [MangaSeries] {
                        DataSource.shared.browseSeriesList = currentMangaBrowseSeriesList + mangaSeriesList
                    }
                    return
                }
                
                var indexPathsForNewItems = [IndexPath]()
                if let animeSeriesList = generalSeriesList as? [AnimeSeries],
                    let currentAnimeBrowseSeriesList = DataSource.shared.browseSeriesList as? [AnimeSeries] {
                    for animeSeries in animeSeriesList {
                        DataSource.shared.browseSeriesList!.append(animeSeries)
                        let indexPath = IndexPath(item: lastCellIndexPathItem + 1, section: 0)
                        indexPathsForNewItems.append(indexPath)
                    }
                }
                
                DispatchQueue.main.async {
                    self.seriesCollectionView.performBatchUpdates({ 
                        collectionView.insertItems(at: indexPathsForNewItems)
                    }, completion: nil)
                }
                
                print("Number of downloaded series: \(DataSource.shared.browseSeriesList?.count)")
                
            }
        }
    }
    
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
        
        guard browseSeriesList.count > indexPath.row else {
            return cell
        }
        
        let currentSeries = browseSeriesList[indexPath.row]
        
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

extension BrowseViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return FilterModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}


