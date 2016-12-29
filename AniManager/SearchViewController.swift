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
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
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
        
        // Configure the collection view's flow layout
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
        
        activityIndicatorView.startAnimatingAndFadeIn()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        NetworkActivityManager.shared.increaseNumberOfActiveConnections()
        
        AniListClient.shared.getSeriesList(fromPage: 1, ofType: seriesType, andParameters: [:], matchingQuery: searchText) { (seriesList, errorMessage) in
            
            // Error Handling
            guard errorMessage == nil else {
                print(errorMessage!)
                self.activityIndicatorView.stopAnimatingAndFadeOut()
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                    
                    guard errorMessage! != "The resource could not be loaded because the App Transport Security policy requires the use of a secure connection." else {
                        return
                    }
                    
                    if errorMessage! == "Couldn't cast JSON to array of dictionaries" {
                        self.nothingFoundLabel.text = "No \(self.seriesType.rawValue) found"
                        UIView.animate(withDuration: 0.25) {
                            self.nothingFoundLabel.alpha = 1.0
                        }
                    } else {
                        self.errorMessageView.showError(withMessage: errorMessage!)
                    }
                }
                return
            }
            
            guard let seriesList = seriesList else {
                self.errorMessageView.showError(withMessage: "Couldn't get series")
                self.activityIndicatorView.stopAnimatingAndFadeOut()
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                }
                return
            }
            
            /*
                Assign the received series list to the data source's
                searchResultsSeriesList property, reload the series
                collection view and make it visible
             */
            DataSource.shared.searchResultsSeriesList = seriesList
            
            NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                self.seriesCollectionView.reloadData()
                self.activityIndicatorView.stopAnimatingAndFadeOut()
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
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        /*
            Every time the search bar's text changed, the series
            collection view should be hidden and a new series list
            should be requested with the current search text
         */
        seriesCollectionView.alpha = 0.0
        getSeriesList(withSearchText: searchText)
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /*
            The number of items in the section should be equal
            to the number of series in the data source's
            searchResultsSeriesList property
         */
        guard let searchResultsSeriesList = DataSource.shared.searchResultsSeriesList else {
            return 0
        }
        
        return searchResultsSeriesList.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seriesCell", for: indexPath) as! SeriesCollectionViewCell
        
        /*
            Check if there is a results series list and if the number
            of series in the array is higher than the index path's
            row property
         */
        guard let searchResultsSeriesList = DataSource.shared.searchResultsSeriesList,
        searchResultsSeriesList.count > indexPath.row else {
            return cell
        }
        
        /*
            Get the current series from the search results series list
            by getting the item at the index that's equal to the current
            index path's row property
         */
        let currentSeries = searchResultsSeriesList[indexPath.row]
        
        /*
            If the dequeued cell's seriesId property is nil, the current
            series' ID should be assigned to it
         */
        if cell.seriesId == nil {
            cell.seriesId = currentSeries.id
        }
        
        /*
            Set the cell's title label to the current series' title
            and show it
         */
        cell.titleLabel.text = currentSeries.titleEnglish
        cell.titleLabel.isHidden = false
        
        /*
            Check if the cell image view's image property is nil. If it is,
            get image data for the current series' medium image URL string
            and set the image when the data was successfully downloaded
         */
        if cell.imageView.image == nil {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            NetworkActivityManager.shared.increaseNumberOfActiveConnections()
            
            AniListClient.shared.getImageData(fromUrlString: currentSeries.imageMediumUrlString) { (imageData, errorMessage) in
                guard errorMessage == nil else {
                    NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                    }
                    return
                }
                
                guard let imageData = imageData else {
                    NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                    }
                    return
                }
                
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        cell.imageOverlay.isHidden = false
                        cell.imageView.image = image
                    }
                }
                
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                }
            }
        }
        
        return cell
        
    }

    /*
        When the search bar's search button is tapped, the search bar
        should resign its first responder status
     */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

