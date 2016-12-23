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
    
    var seriesId: Int!
    var seriesTitle: String!
    var seriesType: SeriesType! = .manga
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var seriesDataTableView: UITableView!
    
    
    // MARK: - Actions
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: .UIKeyboardWillHide, object: nil)
        
        
        addErrorMessageView(toBottomOf: view, errorMessageView: errorMessageView)
        
        ratingPicker = RatingPicker(frame: CGRect(x: 0, y: view.frame.maxY, width: view.frame.width, height: 300.0))
        ratingPicker!.dismissToolbarButton.target = self
        ratingPicker!.dismissToolbarButton.action = #selector(toggleRatingPickerVisibility)
        ratingPicker!.submitToolbarButton.target = self
        ratingPicker!.submitToolbarButton.action = #selector(changeUserScore)
        ratingPicker!.pickerView.dataSource = self
        ratingPicker!.pickerView.delegate = self
        view.addSubview(ratingPicker!)
        
        /*
            Get a single series object for the specified series ID and series type
            when the view controller is loaded
         */
        AniListClient.shared.getSingleSeries(ofType: seriesType, withId: seriesId) { (series, errorMessage) in
            guard errorMessage == nil else {
                self.errorMessageView.showError(withMessage: errorMessage!)
                return
            }
            
            guard let series = series else {
                self.errorMessageView.showError(withMessage: "Couldn't get series information")
                return
            }
            
            DispatchQueue.main.async {
                self.seriesDataTableView.reloadData()
            }
            
            // MARK: - Banner View Setup
            
            // Set the release year label
            if let seasonId = series.seasonId,
                let releaseYear = self.getReleaseYear(fromSeasonId: seasonId) {
                DispatchQueue.main.async {
                    (self.seriesDataTableView.tableHeaderView as! BannerView).seriesReleaseYearLabel.text = "\(releaseYear)"
                }
            }
            
            // Set the favourite button
            if let isFavorite = series.favorite,
                isFavorite {
                DispatchQueue.main.async {
                    (self.seriesDataTableView.tableHeaderView as! BannerView).favoriteButton.setImage(#imageLiteral(resourceName: "HeartIconActive"), for: .normal)
                }
            }
            
            guard let imageBannerUrlString = series.imageBannerUrlString else {
                return
            }
            
            AniListClient.shared.getImageData(fromUrlString: imageBannerUrlString) { (data, errorMessage) in
                guard errorMessage == nil else {
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                // Set the banner view image
                let bannerImage = UIImage(data: data)
                DispatchQueue.main.async {
                    (self.seriesDataTableView.tableHeaderView as! BannerView).imageView.image = bannerImage
                    UIView.animate(withDuration: 0.25) {
                        (self.seriesDataTableView.tableHeaderView as! BannerView).imageView.alpha = 1.0
                    }
                }
            }
        }
        
        seriesDataTableView.register(UINib(nibName: "ActionsTableViewCell", bundle: nil), forCellReuseIdentifier: "actionsCell")
        seriesDataTableView.register(UINib(nibName: "ImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "imagesCell")
        
        let bannerView = BannerView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 200))
        bannerView.dismissButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        bannerView.favoriteButton.addTarget(self, action: #selector(favorite), for: .touchUpInside)
        bannerView.seriesTitleLabel.text = seriesTitle
        
        seriesDataTableView.tableHeaderView = bannerView
        
        seriesDataTableView.estimatedRowHeight = 300
        seriesDataTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - Functions
    
    func goBack() {
        DataSource.shared.selectedSeries = nil
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
        
        let keyboardFrameEndRect = keyboardFrameEnd as CGRect
        view.frame.origin.y -= keyboardFrameEndRect.height
    }
    
    func keyboardDidHide(_ notification: Notification) {
        view.frame.origin.y = 0.0
    }
    
    func favorite() {
        AniListClient.shared.favorite(seriesOfType: seriesType, withId: seriesId) { (errorMessage) in
            guard errorMessage == nil else {
                self.errorMessageView.showError(withMessage: errorMessage!)
                return
            }
            
            /*
                Check whether the series was favorited or not based on the banner view
                based on the current image and toggle the image (if the image indicates
                that the series is a favorite (filled heart icon) it means that it was
                unfavorited, thus the heart icon should be empty and the other way around)
             */
            DispatchQueue.main.async {
                if (self.seriesDataTableView.tableHeaderView as! BannerView).favoriteButton.image(for: .normal) == #imageLiteral(resourceName: "HeartIconActive") {
                    (self.seriesDataTableView.tableHeaderView as! BannerView).favoriteButton.setImage(#imageLiteral(resourceName: "HeartIcon"), for: .normal)
                } else {
                    (self.seriesDataTableView.tableHeaderView as! BannerView).favoriteButton.setImage(#imageLiteral(resourceName: "HeartIconActive"), for: .normal)
                }
            }
            
        }
    }
    
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
            
            for animeListName in AnimeListName.allNames {
                let listAction = UIAlertAction(title: animeListName, style: .default) { (alertAction) in
                    sender.setTitle(alertAction.title, for: .normal)
                    self.listValueChanged()
                }
                listsAlertController.addAction(listAction)
            }
        } else if seriesType == .manga {
            for mangaListName  in MangaListName.allNames {
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
                    self.errorMessageView.showError(withMessage: "Couldn't remove \(self.seriesType.rawValue) from list")
                    return
                }
                
                /*
                    If the series can be removed from the list, the cell's appearance should
                    be changed accordingly
                 */
                if let actionsCell = self.seriesDataTableView.cellForRow(at: IndexPath(item: 1, section: 0)) as? ActionsTableViewCell {
                    DispatchQueue.main.async {
                        actionsCell.setupCellForStatus(isSeriesInList: false)
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
                self.ratingPicker!.frame.origin.y += self.ratingPicker!.frame.height
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
}

extension SeriesDetailViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
}

extension SeriesDetailViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 1)"
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let ratingLabel = UILabel()
        ratingLabel.font = UIFont(name: Constant.FontName.mainBlack, size: 36.0)
        ratingLabel.textColor = .aniManagerBlack
        ratingLabel.text = "\(row + 1)"
        ratingLabel.textAlignment = .center
        return ratingLabel
    }
}
