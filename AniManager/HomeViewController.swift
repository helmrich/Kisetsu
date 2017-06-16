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
    let featuredSliderActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    let errorMessageView = ErrorMessageView()
    
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
        
        setupInterfaceForCurrentTheme()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setupInterfaceForCurrentTheme), name: .themeSettingChanged, object: nil)
        
        errorMessageView.addToBottom(of: view, withOffsetToBottom: tabBarController != nil ? tabBarController!.tabBar.frame.height : 49.0)
        
        // Add observer for the "settingValueChanged" notification
        NotificationCenter.default.addObserver(self, selector: #selector(settingValueChanged), name: .settingValueChanged, object: nil)
        
        // Register nibs
        tableView.register(UINib(nibName: "ImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "currentlyAiringCell")
        tableView.register(UINib(nibName: "ImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "currentSeasonCell")
        tableView.register(UINib(nibName: "ImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "continueWatchingCell")
        tableView.register(UINib(nibName: "ImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "continueReadingCell")
        tableView.register(UINib(nibName: "ImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "recommendationsCell")
        tableView.register(UINib(nibName: "ImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "mostPopularAnimeCell")
        tableView.register(UINib(nibName: "ImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "topRatedAnimeCell")
        tableView.register(UINib(nibName: "ImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "mostPopularMangaCell")
        tableView.register(UINib(nibName: "ImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "topRatedMangaCell")
        
        
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
        view.addSubview(featuredSliderActivityIndicator)
        featuredSlider.translatesAutoresizingMaskIntoConstraints = false
        featuredSliderActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: featuredSlider, attribute: .top, relatedBy: .equal, toItem: tableView, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: featuredSlider, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: featuredSlider, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: featuredSlider, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.4, constant: 0.0),
            NSLayoutConstraint(item: featuredSliderActivityIndicator, attribute: .centerX, relatedBy: .equal, toItem: featuredSlider, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: featuredSliderActivityIndicator, attribute: .centerY, relatedBy: .equal, toItem: featuredSlider, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        ])
        
        featuredSliderActivityIndicator.startAnimatingAndFadeIn()
        
        tableView.tableHeaderView = featuredSlider
        featuredSlider.imageView.alpha = 0.0
        featuredSlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openTappedFeaturedSeriesDetail)))
        
        view.layoutIfNeeded()
        
        AniListClient.shared.getTopSeries(ofType: .anime, fromYear: DateManager.currentYear) { (featuredSeriesList, errorMessage) in
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
                self.featuredSliderActivityIndicator.stopAnimatingAndFadeOut()
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
            
            DataSource.shared.currentlyAiringSeriesList = seriesList
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
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
            
            DataSource.shared.currentSeasonSeriesList = seriesList
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        if let grantTypeString = UserDefaults.standard.string(forKey: UserDefaultsKey.grantType.rawValue),
            let grantType = GrantType(rawValue: grantTypeString),
            grantType != .clientCredentials {
            AniListClient.shared.getAuthenticatedUser { (user, errorMessage) in
                guard errorMessage == nil else {
                    self.errorMessageView.showAndHide(withMessage: errorMessage!)
                    return
                }
                
                guard let user = user else {
                    self.errorMessageView.showAndHide(withMessage: "Couldn't get authenticated user")
                    return
                }
                
                for seriesType in SeriesType.allValues {
                    let statusKey: String
                    switch seriesType {
                    case .anime:
                        statusKey = AnimeListName.watching.asKey()
                    case .manga:
                        statusKey = MangaListName.reading.asKey()
                    }
                    AniListClient.shared.getList(ofType: seriesType, withStatus: statusKey, userId: user.id, andDisplayName: user.displayName) { (seriesList, errorMessage) in
                        guard errorMessage == nil else {
                            return
                        }
                        
                        guard let seriesList = seriesList else {
                            return
                        }
                        
                        switch seriesType {
                        case .anime:
                            DataSource.shared.continueWatchingSeriesList = seriesList
                        case .manga:
                            DataSource.shared.continueReadingSeriesList = seriesList
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
        
        for seriesType in SeriesType.allValues {
            for sortParameter in AniListClient.SortParameter.allValues {
                AniListClient.shared.getTopSeries(ofType: seriesType, basedOn: sortParameter, fromYear: nil, amount: 20) { (seriesList, errorMessage) in
                    guard errorMessage == nil else {
                        return
                    }
                    
                    guard let seriesList = seriesList else {
                        return
                    }
                    
                    switch (seriesType, sortParameter) {
                    case (.anime, .popularity):
                        DataSource.shared.mostPopularAnimeSeriesList = seriesList
                    case (.anime, .score):
                        DataSource.shared.topRatedAnimeSeriesList = seriesList
                    case (.manga, .popularity):
                        DataSource.shared.mostPopularMangaSeriesList = seriesList
                    case (.manga, .score):
                        DataSource.shared.topRatedMangaSeriesList = seriesList
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
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
    
    func setupInterfaceForCurrentTheme() {
        navigationController?.navigationBar.barTintColor = Style.Color.BarTint.navigationBar
        view.backgroundColor = Style.Color.Background.mainView
        tableView.backgroundColor = Style.Color.Background.tableView
        tableView.reloadData()
    }
    
    func settingValueChanged() {
        tableView.reloadData()
    }
    
    func getSeriesList(forCellOfType type: ImagesTableViewCellType) -> [Series] {
        switch type {
        case .currentSeason:
            return DataSource.shared.currentSeasonSeriesList
        case .continueWatching:
            return DataSource.shared.continueWatchingSeriesList
        case .continueReading:
            return DataSource.shared.continueReadingSeriesList
        case .recommendations:
            return DataSource.shared.recommendationsSeriesList
        case .mostPopularAnime:
            return DataSource.shared.mostPopularAnimeSeriesList
        case .topRatedAnime:
            return DataSource.shared.topRatedAnimeSeriesList
        case .mostPopularManga:
            return DataSource.shared.mostPopularMangaSeriesList
        case .topRatedManga:
            return DataSource.shared.topRatedMangaSeriesList
        default:
            return DataSource.shared.currentlyAiringSeriesList
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
