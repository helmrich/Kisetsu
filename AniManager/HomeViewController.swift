//
//  HomeViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 22.05.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    // MARK: - Properties
    
    let featuredSlider = FeaturedSlider()
    let errorMessageView = ErrorMessageView()
    
    var currentlyAiringSeriesList = [Series]()
    var currentSeasonSeriesList = [Series]()
    var continueWatchingSeriesList = [Series]()
    var continueReadingSeriesList = [Series]()
    var recommendationsSeriesList = [Series]()
    
    var statusBarShouldBeHidden = false
    
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var originalTableViewTopConstraint: NSLayoutConstraint!
    
    
    // MARK: - Actions
    
    
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = true
        
        errorMessageView.addToBottom(of: view, withOffsetToBottom: 49.0)
        
        // Add observer for the "settingValueChanged" notification
        NotificationCenter.default.addObserver(self, selector: #selector(settingValueChanged), name: Notification.Name(rawValue: Constant.NotificationKey.settingValueChanged), object: nil)
        
        tableView.register(UINib(nibName: "ImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "currentlyAiringCell")
        tableView.register(UINib(nibName: "ImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "currentSeasonCell")
        tableView.register(UINib(nibName: "ImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "continueWatchingCell")
        tableView.register(UINib(nibName: "ImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "continueReadingCell")
        tableView.register(UINib(nibName: "ImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "recommendationsCell")
        
        featuredSlider.setBackgroundColor()
        
        tableView.estimatedRowHeight = 300.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        /*
            Remove the original table view top constraint and activate
            a top constraint for the table view that's equal to the main
            view's top attribute with a constant that's equal to the
            navigation bar height + the status bar height.
         
            This has to be done in order to prevent jumping of the table view
            when the top constraint is attached to the navigation bar and the
            status bar is hidden and shown again.
         */
        view.removeConstraint(originalTableViewTopConstraint)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: navigationController != nil ? navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height : 0.0 + UIApplication.shared.statusBarFrame.height)
            ])
        
        view.addSubview(featuredSlider)
        featuredSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: featuredSlider, attribute: .top, relatedBy: .equal, toItem: tableView, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: featuredSlider, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: featuredSlider, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: featuredSlider, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.4, constant: 0.0),
        ])
        
        tableView.tableHeaderView = featuredSlider
        featuredSlider.imageView.alpha = 0.0
        featuredSlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openTappedFeaturedSeriesDetail)))
        
        view.layoutIfNeeded()
        
        AniListClient.shared.getTopSeries(fromYear: DateManager.currentYear) { (featuredSeriesList, errorMessage) in
            guard errorMessage == nil else {
                self.errorMessageView.showAndHide(withMessage: errorMessage!)
                return
            }
            
            guard let featuredSeriesList = featuredSeriesList else {
                self.errorMessageView.showAndHide(withMessage: "Couldn't get featured series")
                return
            }
            
            DispatchQueue.main.async {
                self.featuredSlider.seriesList = featuredSeriesList
                self.featuredSlider.layoutSubviews()
                self.featuredSlider.isAutomaticSlidingEnabled = true
                UIView.animate(withDuration: 0.25) {
                    self.featuredSlider.imageView.alpha = 1.0
                }
            }
        }
        
        AniListClient.shared.getCurrentlyAiringAnime(amount: 20) { (seriesList, errorMessage) in
            guard errorMessage == nil else {
                self.errorMessageView.showAndHide(withMessage: errorMessage!)
                return
            }
            
            guard let seriesList = seriesList else {
                self.errorMessageView.showAndHide(withMessage: "Couldn't get currently airing anime")
                return
            }
            
            self.currentlyAiringSeriesList = seriesList
            
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
            }
            
        }
        
        AniListClient.shared.getCurrentSeasonAnime(amount: 20) { (seriesList, errorMessage) in
            guard errorMessage == nil else {
                self.errorMessageView.showAndHide(withMessage: errorMessage!)
                return
            }
            
            guard let seriesList = seriesList else {
                self.errorMessageView.showAndHide(withMessage: "Couldn't get anime for the current season")
                return
            }
            
            self.currentSeasonSeriesList = seriesList
            
            seriesList.forEach {
                print("\($0.titleRomaji): \($0.popularity)")
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
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
    
    func settingValueChanged() {
        tableView.reloadData()
    }
    
    func getSeriesList(forCellOfType type: ImagesTableViewCellType) -> [Series] {
        switch type {
        case .currentSeason:
            return currentSeasonSeriesList
        case .continueWatching:
            return continueWatchingSeriesList
        case .continueReading:
            return continueReadingSeriesList
        case .recommendations:
            return recommendationsSeriesList
        default:
            return currentlyAiringSeriesList
        }
    }
    
    func openTappedFeaturedSeriesDetail() {
        guard let currentlySelectedFeaturedSeries = featuredSlider.currentlySelectedSeries else {
            errorMessageView.showAndHide(withMessage: "Can't display series detail")
            return
        }
        
        presentSeriesDetail(forSeriesWithId: currentlySelectedFeaturedSeries.id, seriesTitle: featuredSlider.titleLabel.text != nil ? featuredSlider.titleLabel.text! : currentlySelectedFeaturedSeries.titleEnglish, seriesType: currentlySelectedFeaturedSeries.seriesType)
    }
    
    func presentSeriesDetail(forSeriesWithId id: Int, seriesTitle: String, seriesType: SeriesType) {
        let seriesDetailViewController = storyboard!.instantiateViewController(withIdentifier: "seriesDetailViewController") as! SeriesDetailViewController
        seriesDetailViewController.seriesId = id
        seriesDetailViewController.seriesTitle = seriesTitle
        seriesDetailViewController.seriesType = seriesType
        statusBarShouldBeHidden = true
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        present(seriesDetailViewController, animated: true, completion: nil)
    }
}


// MARK: - Table View Delegate

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellTitle: String
        let cellType: ImagesTableViewCellType
        
        if indexPath.row == 0 {
            cellType = .currentlyAiring
            cellTitle = "Currently Airing"
        } else if indexPath.row == 1 {
            cellType = .currentSeason
            cellTitle = "Current Season"
        } else if indexPath.row == 2 {
            cellType = .recommendations
            cellTitle = "Recommendations"
        } else if indexPath.row == 3 {
            cellType = .continueWatching
            cellTitle = "Continue Watching"
        } else if indexPath.row == 4 {
            cellType = .continueReading
            cellTitle = "Continue Reading"
        } else {
            return UITableViewCell(frame: CGRect.zero)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(cellType.rawValue)Cell") as! ImagesTableViewCell
        cell.type = cellType
        cell.titleLabel.text = cellTitle
        
        cell.imagesCollectionView.register(UINib(nibName: "ImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "imagesCollectionViewCell")
        cell.imagesCollectionViewFlowLayout.itemSize = CGSize(width: (view.bounds.width / 3.5) > 100 ? 100 : (view.bounds.width / 3.5), height: (view.bounds.width / 3.5) > 100 ? 100 : (view.bounds.width / 3.5))
        cell.imagesCollectionViewFlowLayout.minimumLineSpacing = 1
        
        cell.imagesCollectionView.dataSource = self
        cell.imagesCollectionView.delegate = self
        
        cell.imagesCollectionView.reloadData()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let grantTypeString = UserDefaults.standard.string(forKey: "grantType"),
            let grantType = GrantType(rawValue: grantTypeString) else {
                return 3
        }
        
        if grantType == .clientCredentials {
            return 3
        } else {
            return 5
        }
    }
}

// MARK: - Table View Delegate

extension HomeViewController: UITableViewDelegate {
    
}


// MARK: - Collection View Data Source

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagesCollectionViewCell", for: indexPath) as! ImagesCollectionViewCell
        
        cell.imageOverlayView.alpha = 0.6
        
        /*
             Set the cell's type property to the same value as its
             collection view's table view cell's type property.
             Note: The first superview property is the table view cell's
             content view, the second one is the actual table view cell.
         */
        guard let imagesTableViewCellType = (collectionView.superview?.superview as? ImagesTableViewCell)?.type else {
            return cell
        }
        
        cell.imagesTableViewCellType = imagesTableViewCellType
        
        let seriesList = getSeriesList(forCellOfType: imagesTableViewCellType)
        
        // TODO: Just using featured series for testing purposes, replace with
        // appropriate series
        guard seriesList.count > 0,
            seriesList.count > indexPath.row else {
            return cell
        }
        
        let currentSeries = seriesList[indexPath.row]
        
        guard let imageMediumUrl = URL(string: currentSeries.imageMediumUrlString) else {
                return cell
        }
        
        cell.titleLabel.text = currentSeries.titleForSelectedTitleLanguageSetting
        UIView.animate(withDuration: 0.25) {
            cell.titleLabel.alpha = 1.0
        }
        
        if cell.imageView.image == nil {
            cell.imageView.kf.setImage(with: imageMediumUrl, placeholder: UIImage.with(color: .aniManagerGray, andSize: cell.imageView.bounds.size), options: [.transition(.fade(0.25))], progressBlock: nil) { (_, _, _, _) in
                collectionView.reloadItems(at: [indexPath])
            }
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let imagesTableViewCellType = (collectionView.superview?.superview as? ImagesTableViewCell)?.type else {
            return 0
        }
        
        let seriesList = getSeriesList(forCellOfType: imagesTableViewCellType)
        
        if seriesList.count == 0 {
            return 20
        }
        
        return seriesList.count
        
    }
}


// MARK: - Collection View Delegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imagesCollectionViewCell", for: indexPath) as! ImagesCollectionViewCell
        guard let cellType = cell.imagesTableViewCellType else {
            return
        }
        
        let seriesList = getSeriesList(forCellOfType: cellType)
        
        guard indexPath.row < seriesList.count else {
            return
        }
        
        let selectedSeries = seriesList[indexPath.row]
        
        let seriesTitle = selectedSeries.titleForSelectedTitleLanguageSetting
        
        presentSeriesDetail(forSeriesWithId: seriesList[indexPath.row].id, seriesTitle: seriesTitle, seriesType: seriesList[indexPath.row].seriesType)
        
    }
}






