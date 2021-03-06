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
    
    var seriesCollectionViewBottomConstraint: NSLayoutConstraint! = NSLayoutConstraint()
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var seriesTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var seriesCollectionView: UICollectionView!
    @IBOutlet weak var seriesCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var originalSeriesCollectionViewBottomConstraint: NSLayoutConstraint?
    
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
        
        setupInterfaceForCurrentTheme()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupInterfaceForCurrentTheme), name: .themeSettingChanged, object: nil)
        
        seriesCollectionViewBottomConstraint = NSLayoutConstraint(item: seriesCollectionView, attribute: .bottom, relatedBy: .equal, toItem: tabBarController != nil ? tabBarController!.tabBar : view, attribute: .top, multiplier: 1.0, constant: 0.0)
        
        // Add observer for the "settingValueChanged" notification
        NotificationCenter.default.addObserver(self, selector: #selector(settingValueChanged), name: .settingValueChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Configure the collection view's flow layout
        configure(seriesCollectionViewFlowLayout)
        
        // Add a tap gesture recognizer to the main view
        let mainViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        mainViewTapGestureRecognizer.delegate = self
        view.addGestureRecognizer(mainViewTapGestureRecognizer)
        
        /*
            Set the search bar's background image property
            to an empty image object so that there is no
            visible border at the top and bottom of it
         */
        searchBar.backgroundImage = UIImage()
        setSeriesTypeFromSelectedSegment()
    }
    
    
    // MARK: - Functions
    
    func setupInterfaceForCurrentTheme() {
        view.backgroundColor = Style.Color.Background.mainView
        activityIndicatorView.activityIndicatorViewStyle = Style.ActivityIndicatorView.lightDark
        navigationController?.navigationBar.barTintColor = Style.Color.BarTint.navigationBar
        searchBar.backgroundColor = Style.Color.Background.searchBar
        seriesCollectionView.backgroundColor = Style.Color.Background.collectionView
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let originalSeriesCollectionViewBottomConstraint = originalSeriesCollectionViewBottomConstraint {
            view.removeConstraint(originalSeriesCollectionViewBottomConstraint)
            self.originalSeriesCollectionViewBottomConstraint = nil
        }
        
        guard let userInfo = notification.userInfo,
            let keyboardSizeValue = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue else {
                return
        }
        
        let keyboardHeight = keyboardSizeValue.cgRectValue.height
        view.removeConstraint(seriesCollectionViewBottomConstraint)
        seriesCollectionViewBottomConstraint = NSLayoutConstraint(item: seriesCollectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -keyboardHeight)
        view.addConstraint(seriesCollectionViewBottomConstraint)
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.removeConstraint(seriesCollectionViewBottomConstraint)
        seriesCollectionViewBottomConstraint = NSLayoutConstraint(item: seriesCollectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: tabBarController != nil ? -tabBarController!.tabBar.frame.height : 0.0)
        view.addConstraint(seriesCollectionViewBottomConstraint)
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    func settingValueChanged() {
        seriesCollectionView.reloadData()
    }
    
    /*
        This method takes a search text string as a parameter
        which it passes to the getSeriesList method's matchingQuery
        parameter
     */
    func getSeriesList(withSearchText searchText: String) {
        
        seriesCollectionView.alpha = 0.0
        activityIndicatorView.startAnimatingAndFadeIn()
        UIView.animate(withDuration: 0.25) {
            self.nothingFoundLabel.alpha = 0.0
        }
        
        NetworkActivityManager.shared.increaseNumberOfActiveConnections()
        AniListClient.shared.getSeriesList(fromPage: 1, ofType: seriesType, andParameters: [:], matchingQuery: searchText) { (seriesList, nonAdultSeriesList, errorMessage) in
            // Error Handling
            guard errorMessage == nil else {
                self.activityIndicatorView.stopAnimatingAndFadeOut()
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                DispatchQueue.main.async {
                    guard errorMessage! != "The resource could not be loaded because the App Transport Security policy requires the use of a secure connection." else {
                        return
                    }
                    
                    if errorMessage! == "Couldn't cast JSON to array of dictionaries" {
                        self.nothingFoundLabel.text = "No \(self.seriesType.rawValue) found"
                        UIView.animate(withDuration: 0.25) {
                            self.nothingFoundLabel.alpha = 1.0
                        }
                    } else {
                        self.errorMessageView.showAndHide(withMessage: errorMessage!)
                    }
                }
                return
            }
            
            guard let seriesList = seriesList,
            let nonAdultSeriesList = nonAdultSeriesList else {
                self.errorMessageView.showAndHide(withMessage: "Couldn't get series")
                self.activityIndicatorView.stopAnimatingAndFadeOut()
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                return
            }
            
            /*
                Depending on whether the display of explicit content is
                activated or not, assign the received series list to the
                data source's searchResultsSeriesList property, reload the
                series collection view and make it visible
             */
            let seriesListToShow = UserDefaults.standard.bool(forKey: UserDefaultsKey.showExplicitContent.rawValue) ? seriesList : nonAdultSeriesList
            let seriesListSortedByPopularity = seriesListToShow.sorted { (lhsSeries, rhsSeries) -> Bool in
                return lhsSeries.popularity > rhsSeries.popularity
            }
            
            DataSource.shared.searchResultsSeriesList = seriesListSortedByPopularity
            
            NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
            DispatchQueue.main.async {
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
            should be requested with the current search text, if the
            search text contains at least one character
         */
        if searchText.characters.count > 0 {
            getSeriesList(withSearchText: searchText)
        }
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
        cell.titleLabel.text = currentSeries.titleForSelectedTitleLanguageSetting
        cell.titleLabel.alpha = 1.0
        cell.imageView.backgroundColor = Style.Color.Background.seriesCollectionImageView
        cell.imageOverlay.alpha = 0.7
        
        /*
            Check if the cell image view's image property is nil. If it is,
            get image data for the current series' medium image URL string
            and set the image when the data was successfully downloaded
         */
        if cell.imageView.image == nil,
            let imageMediumURL = URL(string: currentSeries.imageMediumURLString),
            let imageLargeURL = URL(string: currentSeries.imageLargeURLString) {
            cell.imageView.kf.setImage(
                with: UserDefaults.standard.bool(forKey: UserDefaultsKey.downloadHighQualityImages.rawValue) ? imageLargeURL : imageMediumURL,
                placeholder: nil, options: [.transition(.fade(0.25))], progressBlock: nil, completionHandler: nil)
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

extension SearchViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        /*
            Check if the touch happens in one of the series collection
            view's visible cells. If it does, the gesture recognizer
            shouldn't receive the touch or otherwise nothing will happen
            when the collection view's cells are touched because the
            main view's gesture recognizer will receive the touches instead
         */
        var touchIsInCollectionViewCell = false
        for cell in seriesCollectionView.visibleCells {
            if cell.bounds.contains(touch.location(in: cell)) {
                touchIsInCollectionViewCell = true
            }
        }
        return !touchIsInCollectionViewCell
    }
}

