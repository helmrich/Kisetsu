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
    
    
    // MARK: - Actions
    
    @IBAction func changeSeriesType(_ sender: Any) {
        setSeriesTypeFromSelectedSegment()
        guard let searchBarText = searchBar.text,
            searchBarText.characters.count > 0 else {
                return
        }
        getSeriesList(withSearchText: searchBarText)
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addErrorMessageView(toBottomOf: view, errorMessageView: errorMessageView)
        
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
    
    func getSeriesList(withSearchText searchText: String) {
        AniListClient.shared.getSeriesList(fromPage: 1, ofType: seriesType, andParameters: [:], matchingQuery: searchText) { (seriesList, errorMessage) in
            guard errorMessage == nil else {
                print(errorMessage!)
                return
            }
            
            guard let seriesList = seriesList else {
                print("Couldn't get series")
                return
            }
            
            DataSource.shared.searchResultsSeriesList = seriesList
            
            DispatchQueue.main.async {
                self.seriesCollectionView.reloadData()
            }
        }
    }
    
    func setSeriesTypeFromSelectedSegment() {
        guard let selectedSegmentTitle = seriesTypeSegmentedControl.titleForSegment(at: seriesTypeSegmentedControl.selectedSegmentIndex) else {
            return
        }
        let selectedSeriesType = SeriesType(rawValue: selectedSegmentTitle.lowercased())
        seriesType = selectedSeriesType
    }
    
    func mainViewWasTapped() {
        searchBar.resignFirstResponder()
    }

}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
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

