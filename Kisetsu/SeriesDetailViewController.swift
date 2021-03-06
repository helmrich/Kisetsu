//
//  SeriesDetailViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 29.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class SeriesDetailViewController: UIViewController {

    // MARK: - Properties
    
    let errorMessageView = ErrorMessageView()
    var ratingPicker: RatingPicker?
    let seriesDataTableViewActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var seriesId: Int!
    var seriesTitle: String!
    var seriesType: SeriesType! = .manga
    var grantType: GrantType? {
        guard let grantTypeString = UserDefaults.standard.string(forKey: "grantType"),
            let grantType = GrantType(rawValue: grantTypeString) else {
                return nil
        }
        return grantType
    }
    var bannerImageURL: URL?
    
    var availableCellTypes = [SeriesDetailCellType]()
    
    var series: Series? {
        didSet {
            
            /*
                Add the cell types that should always be available to the
                availableCellTypes array
             */
            availableCellTypes = [.basicInformations, .actions]
            
            guard let series = series else { return }
            
            /*
                Check the data that's available for the selected series and
                add the appropriate cell type to the availableCellTypes array
                when data is available
             */
            
            if series.genres.count > 0 {
                availableCellTypes.append(.genres)
            }
            
            if series.description != nil {
                availableCellTypes.append(.description)
            }
            
            if let characters = series.characters,
                characters.count > 0 {
                availableCellTypes.append(.characters)
            }
            
            if let allRelations = series.allRelations,
                allRelations.count > 0 {
                availableCellTypes.append(.relations)
            }
            
            /*
                Append the additionalInformations cell type as additional
                informations should always be available
             */
            availableCellTypes.append(.additionalInformations)
            
            if let tags = series.tags,
                tags.count > 0 {
                availableCellTypes.append(.tags)
            }
            
            if let animeSeries = series as? AnimeSeries,
                let externalLinks = animeSeries.externalLinks,
                externalLinks.count > 0 {
                if let _ = externalLinks.first(where: { $0.siteName.uppercased() == "CRUNCHYROLL" }) {
                    availableCellTypes.append(.episodes)
                }
                availableCellTypes.append(.externalLinks)
            }
            
            if let animeSeries = series as? AnimeSeries,
                let youtubeVideoId = animeSeries.youtubeVideoId,
                let _ = URL(string: "https://www.youtube.com/embed/\(youtubeVideoId)") {
                availableCellTypes.append(.video)
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var seriesDataTableView: UITableView!
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add error message view to main view
        errorMessageView.addToBottom(of: view)
        
        // Register the nibs for the actions and images table view cells
        seriesDataTableView.register(UINib(nibName: "ActionsTableViewCell", bundle: nil), forCellReuseIdentifier: "actionsCell")
        seriesDataTableView.register(UINib(nibName: "ImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "characterImagesCell")
        seriesDataTableView.register(UINib(nibName: "ImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "relationImagesCell")
        
        // MARK: - Rating Picker Setup
        
        // Instantiate and configure rating picker:
        ratingPicker = RatingPicker(frame: CGRect(x: 0, y: view.frame.maxY, width: view.frame.width, height: 300.0))
        // - Toolbar buttons target-actions
        ratingPicker!.dismissToolbarButton.target = self
        ratingPicker!.dismissToolbarButton.action = #selector(toggleRatingPickerVisibility)
        ratingPicker!.submitToolbarButton.target = self
        ratingPicker!.submitToolbarButton.action = #selector(changeUserScore)
        // - Picker view data source and delegate
        ratingPicker!.pickerView.dataSource = self
        ratingPicker!.pickerView.delegate = self
        // - Add to main view
        view.addSubview(ratingPicker!)
        
        // MARK: - Banner View Setup
        
        // Create and configure the banner view
        let bannerView = BannerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height * 0.3))
        bannerView.dismissButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        bannerView.favoriteButton.addTarget(self, action: #selector(favorite), for: .touchUpInside)
        bannerView.titleReleaseYearStackView.alpha = 0.0
        bannerView.titleLabel.text = seriesTitle
        seriesDataTableView.tableHeaderView = bannerView
        
        // Set the table view's row height properties
        seriesDataTableView.estimatedRowHeight = 300
        seriesDataTableView.rowHeight = UITableViewAutomaticDimension

        /*
            Add an activity indicator that gets displayed centered
            in the area below the banner view. It should be displayed
            until the series detail is done loading.
         */
        let seriesDataTableViewActivityIndicatorHelperView = UIView()
        seriesDataTableViewActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        seriesDataTableViewActivityIndicatorHelperView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(seriesDataTableViewActivityIndicator)
        view.addSubview(seriesDataTableViewActivityIndicatorHelperView)
        NSLayoutConstraint.activate([
                NSLayoutConstraint(item: seriesDataTableViewActivityIndicatorHelperView, attribute: .top, relatedBy: .equal, toItem: bannerView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: seriesDataTableViewActivityIndicatorHelperView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.7, constant: 0.0),
                NSLayoutConstraint(item: seriesDataTableViewActivityIndicator, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: seriesDataTableViewActivityIndicator, attribute: .centerY, relatedBy: .equal, toItem: seriesDataTableViewActivityIndicatorHelperView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
            ])
        
        setupInterfaceForCurrentTheme()
        
        seriesDataTableViewActivityIndicator.startAnimatingAndFadeIn()
        
        /*
            Get a single series object for the specified series ID and series type
            when the view controller is loaded
         */
        
        NetworkActivityManager.shared.increaseNumberOfActiveConnections()
        
        AniListClient.shared.getSingleSeries(ofType: seriesType, withId: seriesId) { (series, errorMessage) in
            
            // Error Handling
            guard errorMessage == nil else {
                self.errorMessageView.showAndHide(withMessage: errorMessage!)
                self.seriesDataTableViewActivityIndicator.stopAnimatingAndFadeOut()
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                return
            }
            
            guard let series = series else {
                self.errorMessageView.showAndHide(withMessage: "Couldn't get series information")
                self.seriesDataTableViewActivityIndicator.stopAnimatingAndFadeOut()
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                return
            }
            
            DispatchQueue.main.async {
                self.seriesDataTableViewActivityIndicator.stopAnimatingAndFadeOut()
            }
            
            self.series = DataSource.shared.selectedSeries
            
            // Reload the table view's data
            DispatchQueue.main.async {
                self.seriesDataTableView.reloadData()
            }
            
            // Banner View Setup
            
            // Set the release year label
            if let seasonId = series.seasonId,
                let releaseYear = self.getReleaseYear(fromSeasonId: seasonId) {
                DispatchQueue.main.async {
                    (self.seriesDataTableView.tableHeaderView as! BannerView).releaseYearLabel.text = "\(releaseYear)"
                }
            }
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25) {
                    (self.seriesDataTableView.tableHeaderView as! BannerView).titleReleaseYearStackView.alpha = 1.0
                }
            }
            
            // Set the favourite button
            if let isFavorite = series.favorite,
                isFavorite {
                DispatchQueue.main.async {
                    (self.seriesDataTableView.tableHeaderView as! BannerView).favoriteButton.setImage(#imageLiteral(resourceName: "HeartIconActive"), for: .normal)
                }
            }
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25) {
                    (self.seriesDataTableView.tableHeaderView as! BannerView).favoriteButton.alpha = 1.0
                }
            }
            
            // Check if the series has an URL string for a banner image
            if let bannerImageURLString = series.imageBannerURLString,
                let bannerImageURL = URL(string: bannerImageURLString) {
                self.bannerImageURL = bannerImageURL
                
                // Get the banner image from the banner image URL string
                DispatchQueue.main.async {
                    (self.seriesDataTableView.tableHeaderView as! BannerView).imageView.kf.setImage(with: bannerImageURL, placeholder: UIImage.with(color: .aniManagerGray, andSize: (self.seriesDataTableView.tableHeaderView as! BannerView).imageView.bounds.size), options: [.transition(.fade(0.25))], progressBlock: nil) { (_, _, _, _) in
                    }
                }
            }
            
            // If the selected series is an anime try getting an episode list
            if let animeSeries = series as? AnimeSeries,
                let externalLinks = animeSeries.externalLinks,
                let crunchyrollExternalLink = externalLinks.first(where: { $0.siteName.uppercased() == "CRUNCHYROLL" }) {
                CrunchyrollClient.shared.getEpisodeList(forSeriesCrunchyrollURLString: crunchyrollExternalLink.siteURLString) { (episodeList, errorMessage) in
                    guard let episodeCellTypeIndex = self.availableCellTypes.index(of: .episodes),
                    episodeCellTypeIndex < self.availableCellTypes.count else {
                        return
                    }
                    
                    guard errorMessage == nil else {
                        self.availableCellTypes.remove(at: episodeCellTypeIndex)
                        DispatchQueue.main.async {
                            self.seriesDataTableView.reloadData()
                        }
                        return
                    }
                    
                    guard let episodeList = episodeList else {
                        self.availableCellTypes.remove(at: episodeCellTypeIndex)
                        DispatchQueue.main.async {
                            self.seriesDataTableView.reloadData()
                        }
                        return
                    }
                    
                    guard episodeList.count > 0 else {
                        self.availableCellTypes.remove(at: episodeCellTypeIndex)
                        DispatchQueue.main.async {
                            self.seriesDataTableView.reloadData()
                        }
                        return
                    }
                    
                    if self.availableCellTypes.contains(.episodes) {
                        DispatchQueue.main.async {
                            self.seriesDataTableView.reloadData()
                            NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                        }
                    } else {
                        DispatchQueue.main.async {
                            NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        seriesDataTableView.alpha = 0.0
        seriesDataTableView.reloadData()
        UIView.animate(withDuration: 0.75) {
            self.seriesDataTableView.alpha = 1.0
        }
        
        NetworkActivityManager.shared.numberOfActiveConnections = 0
        
        // Add keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove keyboard notifications
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    
    // MARK: - Functions
    
    func setupInterfaceForCurrentTheme() {
        seriesDataTableViewActivityIndicator.activityIndicatorViewStyle = Style.ActivityIndicatorView.lightDark
        view.backgroundColor = Style.Color.Background.mainView
        seriesDataTableView.backgroundColor = Style.Color.Background.tableView
        seriesDataTableViewActivityIndicator.activityIndicatorViewStyle = Style.ActivityIndicatorView.lightDark
    }
    
    func goBack() {
        dismiss(animated: true, completion: nil)
    }
    
    func progressTextFieldWasEdited() {
        listValueChanged()
        view.endEditing(true)
    }
    
    // Notification methods
    func keyboardDidShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
        let keyboardFrameEnd = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        guard let keyboardFrameEndRect = keyboardFrameEnd as? CGRect else {
            return
        }
        
        view.frame.origin.y -= keyboardFrameEndRect.height
    }
    
    func keyboardDidHide(_ notification: Notification) {
        view.frame.origin.y = 0.0
    }
    
    // This function favorites or unfavorites a series with a given type and ID
    func favorite() {
        
        NetworkActivityManager.shared.increaseNumberOfActiveConnections()
        
        AniListClient.shared.favorite(seriesOfType: seriesType, withId: seriesId) { (errorMessage) in
            guard errorMessage == nil else {
                self.errorMessageView.showAndHide(withMessage: errorMessage!)
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                return
            }
            
            /*
                Check whether the series was favorited or not based on the banner view
                based on the current image and toggle the image (if the image indicates
                that the series is a favorite (filled heart icon) it means that it was
                unfavorited, thus the heart icon should be empty and the other way around)
             */
            NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
            DispatchQueue.main.async {
                if (self.seriesDataTableView.tableHeaderView as! BannerView).favoriteButton.image(for: .normal) == #imageLiteral(resourceName: "HeartIconActive") {
                    (self.seriesDataTableView.tableHeaderView as! BannerView).favoriteButton.setImage(#imageLiteral(resourceName: "HeartIcon"), for: .normal)
                } else {
                    (self.seriesDataTableView.tableHeaderView as! BannerView).favoriteButton.setImage(#imageLiteral(resourceName: "HeartIconActive"), for: .normal)
                }
            }
            
        }
    }
    
    /*
        This function creates and presents an alert controller with
        all available lists (e.g. watching, plan to watch, completed, etc.)
        for a certain type. It should usually be called when the series
        data table view's action cell's user list status button is tapped.
     */
    func showLists(_ sender: AniManagerButton) {
        /*
            Create an alert controller and configure its popover presentation
            controller. The popover presentation controller has to be configured
            for iPads or else the app would crash when the alert controller is
            presented
         */
        let listsAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        listsAlertController.popoverPresentationController?.permittedArrowDirections = [.up]
        listsAlertController.popoverPresentationController?.sourceView = sender
        listsAlertController.popoverPresentationController?.sourceRect = CGRect(x: 0, y: sender.bounds.size.height / 2.0, width: view.bounds.size.width, height: 0.0)
        
        /*
            Check the series type and add actions for every available
            list with the list names as titles depending on the type
         */
        if seriesType == .anime {
            for animeListName in AnimeListName.allNameStrings {
                let listAction = UIAlertAction(title: animeListName, style: .default) { (alertAction) in
                    sender.setTitle(alertAction.title, for: .normal)
                    self.listValueChanged()
                }
                listsAlertController.addAction(listAction)
            }
        } else if seriesType == .manga {
            for mangaListName  in MangaListName.allNameStrings {
                let listAction = UIAlertAction(title: mangaListName, style: .default) { (alertAction) in
                    sender.setTitle(alertAction.title, for: .normal)
                    self.listValueChanged()
                }
                listsAlertController.addAction(listAction)
            }
        }
        
        /*
            Add alert actions for removing a series from a list
            and cancelling the alert controller
         */
        let removeFromListAction = UIAlertAction(title: "Remove from List", style: .default) { (alertAction) in
            AniListClient.shared.deleteListEntry(ofType: self.seriesType, withSeriesId: self.seriesId) { (errorMessage) in
                guard errorMessage == nil else {
                    self.errorMessageView.showAndHide(withMessage: "Couldn't remove \(self.seriesType.rawValue) from list")
                    return
                }
                
                /*
                    If the series can be removed from the list, the cell's appearance should
                    be changed accordingly
                 */
                if let actionsCell = self.seriesDataTableView.cellForRow(at: IndexPath(item: 1, section: 0)) as? ActionsTableViewCell {
                    DispatchQueue.main.async {
                        if let grantType = self.grantType {
                            actionsCell.setupCell(forGrantType: grantType, seriesType: self.seriesType, isSeriesInList: false)
                        }
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        listsAlertController.addAction(removeFromListAction)
        listsAlertController.addAction(cancelAction)
        
        present(listsAlertController, animated: true, completion: nil)
    }
    
    /*
        This function hides or shows the rating picker view
        depending on whether it's currently visible or not
     */
    func toggleRatingPickerVisibility() {
        guard ratingPicker != nil else {
            return
        }
        
        UIView.animate(withDuration: 0.25) {
            if self.ratingPicker!.frame.origin.y == self.view.bounds.maxY {
                self.ratingPicker!.frame.origin.y -= self.ratingPicker!.frame.height
            } else {
                self.ratingPicker!.frame.origin.y = self.view.bounds.maxY
            }
        }
    }
    
    /*
        This function changes the user score by first setting the rate button's
        value to the currently selected rating picker value and then calling
        the listValueChanged function which submits the series' current values
        to the server. It then toggles the rating picker's visibility
     */
    func changeUserScore() {
        let actionsCell = seriesDataTableView.cellForRow(at: IndexPath(item: 1, section: 0)) as! ActionsTableViewCell
        let selectedPickerRow = ratingPicker!.pickerView.selectedRow(inComponent: 0)
        actionsCell.rateButton.setTitle("Your Rating: \(selectedPickerRow + 1)", for: .normal)
        listValueChanged()
        toggleRatingPickerVisibility()
    }
    
    func presentEpisodesNavigationController() {
        let episodesNavigationController = storyboard!.instantiateViewController(withIdentifier: "episodesNavigationController") as! UINavigationController
        present(episodesNavigationController, animated: true, completion: nil)
    }
}

extension SeriesDetailViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /*
        The number of rows in the component should be 10 as the
        default rating values range from 1 to 10
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
}

extension SeriesDetailViewController: UIPickerViewDelegate {
    /*
        Create a custom label and configure its properties.
     
        The title should display the rating's value. It should start
        at 1 and end at 10. Because the row starts at 0 the title
        should display the row's value + 1
     */
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let ratingLabel = UILabel()
        ratingLabel.font = UIFont(name: Constant.FontName.mainBlack, size: 36.0)
        ratingLabel.textColor = Style.Color.Text.pickerView
        ratingLabel.text = "\(row + 1)"
        ratingLabel.textAlignment = .center
        return ratingLabel
    }
}

extension SeriesDetailViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let textFieldText = textField.text else {
            return
        }
        textField.text = textFieldText
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard !string.isEmpty else {
            return true
        }
        
        guard let text = textField.text,
            text.characters.count < 4,
        string != "" else {
            return false
        }
        return true
    }
}
