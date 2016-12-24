//
//  SearchViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 18.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class SearchViewController: SeriesCollectionViewController {

    // MARK: - Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var seriesTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var seriesCollectionView: UICollectionView!
    @IBOutlet weak var seriesCollectionViewFlowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var nothingFoundLabel: UILabel!
    
    // MARK: - Actions
    
    @IBAction func changeSeriesType(_ sender: Any) {
        setSeriesTypeFromSelectedSegment()
        
        /*
            Check if the search bar's text is not nil and if the
            number of characters is higher than 0, if it is,
            a new series list should be requested with the search
            bar's text
         */
        guard let searchBarText = searchBar.text,
            searchBarText.characters.count > 0 else {
                return
        }
        getSeriesList(withSearchText: searchBarText)
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
            Add an error message view and configure the collection
            view's flow layout
         */
        configure(seriesCollectionViewFlowLayout)
        
        /*
            Set the search bar's background image property
            to an empty image object so that there is no
            visible border at the top and bottom of it
         */
        searchBar.backgroundImage = UIImage()
        setSeriesTypeFromSelectedSegment()
        
    }
    
    
    // MARK: - Functions
    
    /*
        This method takes a search text string as a parameter
        which it passes to the getSeriesList method's matchingQuery
        parameter
     */
    func getSeriesList(withSearchText searchText: String) {
        AniListClient.shared.getSeriesList(fromPage: 1, ofType: seriesType, andParameters: [:], matchingQuery: searchText) { (seriesList, errorMessage) in
            
            // Error Handling
            guard errorMessage == nil else {
                DispatchQueue.main.async {
                    self.nothingFoundLabel.text = "No \(self.seriesType.rawValue) found"
                    UIView.animate(withDuration: 0.25) {
                        self.nothingFoundLabel.alpha = 1.0
                    }
                }
                return
            }
            
            guard let seriesList = seriesList else {
                self.errorMessageView.showError(withMessage: "Couldn't get series")
                return
            }
            
            /*
                Assign the received series list to the data source's
                searchResultsSeriesList property, reload the series
                collection view and make it visible
             */
            DataSource.shared.searchResultsSeriesList = seriesList
            
            DispatchQueue.main.async {
                self.seriesCollectionView.reloadData()
                UIView.animate(withDuration: 0.25) {
                    self.nothingFoundLabel.alpha = 0.0
                    self.seriesCollectionView.alpha = 1.0
                }
            }
        }
    }
    
    /*
        This function gets a series type from a selected segment
        of the seriesTypeSegmentedControl by first getting the
        title for the selected segment and then initializing
        a SeriesType object with the segment's title as a raw value
     */
    func setSeriesTypeFromSelectedSegment() {
        guard let selectedSegmentTitle = seriesTypeSegmentedControl.titleForSegment(at: seriesTypeSegmentedControl.selectedSegmentIndex) else {
            return
        }
        let selectedSeriesType = SeriesType(rawValue: selectedSegmentTitle.lowercased())
        seriesType = selectedSeriesType
    }
    
//    func mainViewWasTapped() {
//        searchBar.resignFirstResponder()
//    }

}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        seriesCollectionView.alpha = 0.0
        getSeriesList(withSearchText: searchText)
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let searchResultsSeriesList = DataSource.shared.searchResultsSeriesList else {
            return 0
        }
        
        return searchResultsSeriesList.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seriesCell", for: indexPath) as! SeriesCollectionViewCell
        
        guard let searchResultsSeriesList = DataSource.shared.searchResultsSeriesList else {
            return cell
        }
        
        guard searchResultsSeriesList.count > indexPath.row else {
            return cell
        }
        
        let currentSeries = searchResultsSeriesList[indexPath.row]
        
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

