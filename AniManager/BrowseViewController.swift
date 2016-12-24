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
        
        /*
            - Hide the series collection view initially
            - Show and start animating the activity indicator view
            - Add the error message view
            - Configure the series collection view's flow layout
            - Get a series list
         */
        
        seriesCollectionView.alpha = 0.0
        
        activityIndicatorView.startAnimating()
        UIView.animate(withDuration: 0.25) {
            self.activityIndicatorView.alpha = 1.0
        }
        
        addErrorMessageViewToBottomOfView(withOffsetToBottom: 49.0, errorMessageView: errorMessageView)
        configure(seriesCollectionViewFlowLayout)
        
        getSeriesList()
    }
    
    
    // MARK: - Functions
    
    /*
        This function gets a new series list by calling the
        shared AniListClient's getSeriesList method.
     
        It then checks if the received series list's count is
        less than 40 which would mean that the series collection
        view already shows all the series that were found because
        there are 40 series per page and sets the boolean
        showsAllAvailableSeriesItems variable's value accordingly.
     
        In the end the series collection view's data is reloaded
        and made visible and the indicator view hides and stops
        animating
     */
    func getSeriesList() {
        AniListClient.shared.getSeriesList(ofType: seriesType, andParameters: DataSource.shared.browseParameters) { (seriesList, errorMessage) in
            guard errorMessage == nil else {
                self.errorMessageView.showError(withMessage: errorMessage!)
                return
            }
            
            guard let seriesList = seriesList else {
                self.errorMessageView.showError(withMessage: "Couldn't get series list")
                return
            }
            
            if seriesList.count < 40 {
                self.showsAllAvailableSeriesItems = true
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
    
    @IBAction func openFilterModal() {
        /*
            Instantiate the browse filter view controller from the storyboard
            and set its properties. The modal presentation style should be custom
            and the browse view controller should be its transitioning delegate
            as it implements the necessary UIViewControllerTransitioningDelegate's
            method
         */
        let filterViewController = storyboard!.instantiateViewController(withIdentifier: "browseFilterViewController") as! BrowseFilterViewController
        filterViewController.modalPresentationStyle = .custom
        filterViewController.transitioningDelegate = self
        filterViewController.seriesType = seriesType
        UIView.animate(withDuration: 0.5) {
            self.seriesCollectionView.alpha = 0.5
        }
        self.present(filterViewController, animated: true, completion: nil)
    }
    
    
    // MARK: - Collection View Delegate
    
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
            
            AniListClient.shared.getSeriesList(fromPage: Int(DataSource.shared.browseSeriesList!.count / 40) + 1, ofType: seriesType, andParameters: DataSource.shared.browseParameters) { (seriesList, errorMessage) in
                
                // Error Handling
                guard errorMessage == nil else {
                    self.errorMessageView.showError(withMessage: errorMessage!)
                    return
                }

                guard let generalSeriesList = seriesList else {
                    self.errorMessageView.showError(withMessage: "Couldn't get series list")
                    return
                }
                
                // Check if it's the last page with new series
                if generalSeriesList.count < 40 {
                    self.showsAllAvailableSeriesItems = true
                }

                /*
                    Create an empty array that should hold all the new items'
                    index paths. 
                 
                    Then cast the received series list to the
                    appropriate type and loop through the casted array and
                    append each series to the data source's browseSeriesList
                    array, create an index path for the series and append it
                    to the indexPathsForNewItems array
                 */
                var indexPathsForNewItems = [IndexPath]()
                if self.seriesType == .anime {
                    if let animeSeriesList = generalSeriesList as? [AnimeSeries],
                        let _ = DataSource.shared.browseSeriesList as? [AnimeSeries] {
                        for animeSeries in animeSeriesList {
                            DataSource.shared.browseSeriesList!.append(animeSeries)
                            let indexPath = IndexPath(item: lastCellIndexPathItem + 1, section: 0)
                            indexPathsForNewItems.append(indexPath)
                        }
                        
                    }
                } else if self.seriesType == .manga {
                    if let mangaSeriesList = generalSeriesList as? [MangaSeries],
                        let _ = DataSource.shared.browseSeriesList as? [MangaSeries] {
                        for mangaSeries in mangaSeriesList {
                            DataSource.shared.browseSeriesList!.append(mangaSeries)
                            let indexPath = IndexPath(item: lastCellIndexPathItem + 1, section: 0)
                            indexPathsForNewItems.append(indexPath)
                        }
                    }
                } else {
                    return
                }
                
                /*
                    Insert new items in the series collection view at all the index
                    paths in the indexPathsForNewItems array
                 */
                DispatchQueue.main.async {
                    self.seriesCollectionView.performBatchUpdates({
                        collectionView.insertItems(at: indexPathsForNewItems)
                    }, completion: nil)
                }
            }
        }
    }
}


// MARK: - Collection View Data Source

extension BrowseViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let browseSeriesList = DataSource.shared.browseSeriesList else {
            return 0
        }
        
        return browseSeriesList.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seriesCell", for: indexPath) as! SeriesCollectionViewCell
        
        /*
            Check if the browse series list in the data source is not nil
            and if the number of items in the browse series list is higher
            than the current index path's row (because the index path's row
            starts at 0 but the count at 1)
         */
        guard let browseSeriesList = DataSource.shared.browseSeriesList else {
            return cell
        }
        
        guard browseSeriesList.count > indexPath.row else {
            return cell
        }
        
        /*
            Get the current series from the browse series list,
            if the cell doesn't have a series ID, assign the current
            series' ID to the cells seriesId property and set the
            cell's title label to the current series' title and
            show it
         
            Then download the cover image and set the cell's image
            view's image property to the received image
         */
        let currentSeries = browseSeriesList[indexPath.row]
        
        if cell.seriesId == nil {
            cell.seriesId = currentSeries.id
        }
        
        DispatchQueue.main.async {
            cell.titleLabel.text = currentSeries.titleEnglish
            cell.titleLabel.isHidden = false
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
                        cell.imageView.image = image
                    }
                }
            }
        }
        
        return cell
        
    }
}


// MARK: - View Controller Transitioning Delegate

extension BrowseViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return FilterModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
