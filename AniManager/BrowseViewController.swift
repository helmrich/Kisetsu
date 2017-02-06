//
//  BrowseViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 22.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit
import CoreData

class BrowseViewController: SeriesCollectionViewController {

    // MARK: - Properties
    
    var refreshControl: UIRefreshControl!
    var showsAllAvailableSeriesItems = false
    var managedContext: NSManagedObjectContext!
    var browseList: SeriesList?
    
    var numberOfBasicSeriesInBrowseList: Int {
        guard let browseList = browseList,
            let basicSeries = browseList.basicSeries else {
                return 0
        }
        
        return basicSeries.count
    }
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var seriesCollectionView: UICollectionView!
    @IBOutlet weak var seriesCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var nothingFoundLabel: UILabel!
    
    // MARK: - Actions
    
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
    
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add observer for the "settingValueChanged" notification
        NotificationCenter.default.addObserver(self, selector: #selector(settingValueChanged), name: Notification.Name(rawValue: Constant.NotificationKey.settingValueChanged), object: nil)
        
        /*
            Get the data with the selected browse filters from the user defaults and
            unarchive the data so it becomes an object. Try casting the object to the
            shared data source's selectedBrowseFilters' properties type and assign the
            user default's selected browse filters to the shared data source's
            selectedBrowseFilters property
         */
        if let selectedBrowseFiltersDictionaryData = UserDefaults.standard.object(forKey: "selectedBrowseFiltersData") as? Data,
            let selectedBrowseFiltersObject = NSKeyedUnarchiver.unarchiveObject(with: selectedBrowseFiltersDictionaryData),
            let selectedBrowseFilters = selectedBrowseFiltersObject as? [String:[IndexPath:String]?] {
            DataSource.shared.selectedBrowseFilters = selectedBrowseFilters
            DataSource.shared.setBrowseParameters()
        }
        
        /*
            Get the user default's browse series type and set the view controller's
            seriesType property to its value
         */
        if let userDefaultsSeriesTypeString = UserDefaults.standard.value(forKey: "browseSeriesType") as? String,
            let userDefaultsSeriesType = SeriesType(rawValue: userDefaultsSeriesTypeString) {
            seriesType = userDefaultsSeriesType
        }
        
        tabBarController?.delegate = self
        
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = true
        
        /*
            Create the refresh control, add a target-action to it and assign it
            to the series collection view's refreshControl property
         */
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshList), for: [.valueChanged])
        seriesCollectionView.refreshControl = refreshControl
        
        // Get the managed context from the app delegate
        managedContext = (UIApplication.shared.delegate as! AppDelegate).coreDataStack.managedContext
        
        // Configure the series collection view's flow layout
        configure(seriesCollectionViewFlowLayout)
        
        /*
            Fetch all series lists whose type is "browse" which should normally
            return one result. If the number of results is higher than 0, the
            first item of the results should be assigned to the browseList property
            and the series collection view should be refreshed
         
            If there are no results it means that it's the first time a browse list
            is requested. Thus, when it's the first time a SeriesList managed object
            should be created and assigned to the browseList property. Then, its
            type property should be set, the managed context should be saved and a
            series list should be requested by calling getSeriesList.
         */
        let browseListFetchRequest: NSFetchRequest<SeriesList> = SeriesList.fetchRequest()
        browseListFetchRequest.predicate = NSPredicate(format: "type == %@", argumentArray: ["browse"])
        
        do {
            let results = try managedContext.fetch(browseListFetchRequest)
            if results.count > 0 {
                browseList = results.first
                seriesCollectionView.reloadData()
            } else {
                browseList = SeriesList(context: managedContext)
                browseList?.type = "browse"
                try managedContext.save()
                getSeriesList()
            }
        } catch let error as NSError {
            print("Error when fetching browse list: \(error), \(error.userInfo)")
        }
        
        AniListClient.shared.getGenreList { (genreList, errorMessage) in
            guard errorMessage == nil else {
                return
            }
            
            guard genreList != nil else {
                return
            }
            
            DataSource.shared.getGenres()
            
        }
    }
    
    
    // MARK: - Functions
    
    func refreshList() {
        showsAllAvailableSeriesItems = false
        getSeriesList()
    }
    
    func settingValueChanged() {
        seriesCollectionView.reloadData()
    }
    
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
        
        activityIndicatorView.startAnimatingAndFadeIn()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        NetworkActivityManager.shared.increaseNumberOfActiveConnections()
        
        AniListClient.shared.getSeriesList(ofType: seriesType, andParameters: DataSource.shared.browseParameters) { (seriesList, nonAdultSeriesList, errorMessage) in
            guard errorMessage == nil else {
                self.errorMessageView.showAndHide(withMessage: errorMessage!)
                self.activityIndicatorView.stopAnimatingAndFadeOut()
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                }
                return
            }
            
            guard let seriesList = seriesList,
            let nonAdultSeriesList = nonAdultSeriesList else {
                self.errorMessageView.showAndHide(withMessage: "Couldn't get series list")
                self.activityIndicatorView.stopAnimatingAndFadeOut()
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                }
                return
            }
            
            if seriesList.count < 40 {
                self.showsAllAvailableSeriesItems = true
            }
            
            guard self.browseList != nil else {
                self.errorMessageView.showAndHide(withMessage: "Couldn't find browse list")
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                }
                return
            }
            
            /*
                When getSeriesList is called an entirely new browse list should
                be requested, so the browseList property's basicSeries property
                should be set to an empty set
             */
            guard self.browseList != nil else {
                self.errorMessageView.showAndHide(withMessage: "Couldn't get browse list")
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                }
                return
            }
            
            self.browseList!.basicSeries = []
            
            /*
                Iterate over all series in the received series list or non-adult
                series list (depending on whether explicit content is activated
                or not), create a BasicSeries object for each series, set its
                properties and add it to the browse list
             */
            let seriesListToShow = UserDefaults.standard.bool(forKey: "showExplicitContent") ? seriesList : nonAdultSeriesList
            for series in seriesListToShow {
                let basicSeries = BasicSeries(context: self.managedContext)
                basicSeries.id = Int32(series.id)
                basicSeries.titleEnglish = series.titleEnglish
                basicSeries.titleRomaji = series.titleRomaji
                basicSeries.titleJapanese = series.titleJapanese
                basicSeries.averageScore = series.averageScore
                basicSeries.popularity = Int32(series.popularity)
                basicSeries.imageMediumUrlString = series.imageMediumUrlString
                basicSeries.seriesType = series.seriesType.rawValue
                basicSeries.isAdult = series.isAdult
                self.browseList!.addToBasicSeries(basicSeries)
            }
            
            // Save the managed context
            do {
                try self.managedContext.save()
            } catch let error as NSError {
                print("Error when trying to save context: \(error), \(error.userInfo)")
            }
            
            /*
                - Hide the activity indicator view
                - Reload and show the series collection view
                - End the refresh control's refreshing status
             */
            self.activityIndicatorView.stopAnimatingAndFadeOut()
            NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                self.seriesCollectionView.reloadData()
                self.refreshControl.endRefreshing()
                UIView.animate(withDuration: 0.25) {
                    self.seriesCollectionView.alpha = 1.0
                }
            }
        }
    }
    
    
    // MARK: - Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard browseList != nil else {
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
        if indexPath.row + 1 == numberOfBasicSeriesInBrowseList && !showsAllAvailableSeriesItems {
            
            /*
                Get the last cell's index paths so that new items can be inserted
                after it
            */
            let lastCellIndexPathItem = numberOfBasicSeriesInBrowseList - 1
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            NetworkActivityManager.shared.increaseNumberOfActiveConnections()
            
            /*
                Set the page number the series list should be requested from
                depending on whether all series are in the browse list or not
                (for example when adult series are filtered from the list)
             */
            let pageNumber: Int
            if numberOfBasicSeriesInBrowseList % 40 != 0 {
                pageNumber = Int(numberOfBasicSeriesInBrowseList / 40 + 1) + 1
            } else {
                pageNumber = Int(numberOfBasicSeriesInBrowseList / 40) + 1
            }
            
            AniListClient.shared.getSeriesList(fromPage: pageNumber, ofType: seriesType, andParameters: DataSource.shared.browseParameters) { (seriesList, nonAdultSeriesList, errorMessage) in
                
                // Error Handling
                guard errorMessage == nil else {
                    self.errorMessageView.showAndHide(withMessage: errorMessage!)
                    NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                    }
                    return
                }

                guard let seriesList = seriesList,
                let nonAdultSeriesList = nonAdultSeriesList else {
                    self.errorMessageView.showAndHide(withMessage: "Couldn't get series list")
                    NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                    }
                    return
                }
                
                // Check if it's the last page with new series
                if seriesList.count < 40 {
                    self.showsAllAvailableSeriesItems = true
                }

                /*
                    Create an empty array that should hold all the new items'
                    index paths. 
                 
                    Then - depending on whether explicit content should be displayed or
                    not - define which list ("normal" or non-adult) should be used and
                    iterate over all series in this series list, create a basic series
                    object and an index path for each series, set the basic series
                    object's properties and add it to the browse list's basic series.
                 */
                let seriesListToShow = UserDefaults.standard.bool(forKey: "showExplicitContent") ? seriesList : nonAdultSeriesList
                var indexPathsForNewItems = [IndexPath]()
                for series in seriesListToShow {
                    let basicSeries = BasicSeries(context: self.managedContext)
                    basicSeries.id = Int32(series.id)
                    basicSeries.titleEnglish = series.titleEnglish
                    basicSeries.titleRomaji = series.titleRomaji
                    basicSeries.titleJapanese = series.titleJapanese
                    basicSeries.averageScore = series.averageScore
                    basicSeries.popularity = Int32(series.popularity)
                    basicSeries.imageMediumUrlString = series.imageMediumUrlString
                    basicSeries.seriesType = series.seriesType.rawValue
                    basicSeries.isAdult = series.isAdult
                    self.browseList?.addToBasicSeries(basicSeries)
                    
                    let indexPath = IndexPath(item: lastCellIndexPathItem + 1, section: 0)
                    indexPathsForNewItems.append(indexPath)
                }
                
                /*
                    Insert new items in the series collection view at all the index
                    paths in the indexPathsForNewItems array
                 */
                NetworkActivityManager.shared.decreaseNumberOfActiveConnections()
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = NetworkActivityManager.shared.numberOfActiveConnections > 0
                    self.seriesCollectionView.performBatchUpdates({
                        collectionView.insertItems(at: indexPathsForNewItems)
                    }, completion: nil)
                }
            }
        }
    }
}


// MARK: - View Controller Transitioning Delegate

extension BrowseViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return FilterModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension BrowseViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        /*
            Check if the selected view controller's navigation bar's tag
            property is 1 which indicates that it's the browse view controller's
            navigation controller.
         
            Also check if the tab bar controller's currently active view controller
            is the same as the selected view controller because the browse view
            controller should only scroll to the top if its tab bar button item
            is tapped when it's already active.
         
            Finally, try casting the selected view controller's (navigation controller)
            first child view controller to BrowseViewController type and scroll to
            its series collection view's topmost item
         */
        if (viewController as? UINavigationController)?.navigationBar.tag == 1 && viewController == tabBarController.selectedViewController,
            let browseViewController = viewController.childViewControllers.first as? BrowseViewController {
            browseViewController.seriesCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        }
        return true
    }
}
