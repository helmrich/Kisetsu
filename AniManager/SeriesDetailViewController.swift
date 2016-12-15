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
        
        addErrorMessageView(toBottomOf: view, errorMessageView: errorMessageView)
        
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
        dismiss(animated: true, completion: nil)
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
        let listsAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if seriesType == .anime {
            for animeListName in AnimeListName.allNames() {
                let listAction = UIAlertAction(title: animeListName, style: .default) { (alertAction) in
                    sender.setTitle(alertAction.title, for: .normal)
                    self.listValueChanged()
                }
                listsAlertController.addAction(listAction)
            }
        } else if seriesType == .manga {
            for mangaListName  in MangaListName.allNames() {
                let listAction = UIAlertAction(title: mangaListName, style: .default) { (alertAction) in
                    sender.setTitle(alertAction.title, for: .normal)
                }
                listsAlertController.addAction(listAction)
            }
        }
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
}
