//
//  FilterModalPresentationController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 28.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class FilterModalPresentationController: UIPresentationController {
    
    /*
        The FilterModalPresentationController implements methods for the
        custom presentation and dismissal of a BrowseFilterViewController.
     */
    
    override var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(x: 0, y: containerView!.bounds.maxY - (containerView!.bounds.height / 1.25), width: containerView!.bounds.width, height: containerView!.bounds.height / 1.25)
    }
    
    override func dismissalTransitionWillBegin() {
        /*
            When the modal will be dismissed, loop over all of the tab bar controller's
            child view controllers in order to define the presenting browse view controller.
            If the child view controller can be casted to the browse view controller's type
            the selected parameters should be passed to it, its collection view's alpha value
            should be reset to 1.0 and functions to download a new list and reload the
            collection view should be called.
         */
        for childViewController in (self.presentingViewController as! UITabBarController).childViewControllers {
            
            /*
                Check if the child view controller has child view controllers and
                skip the current iteration of the loop if it doesn't
             */
            if childViewController.childViewControllers == [] {
                continue
            }
            
            /*
                Check if:
                1. The presented view controller can be casted to the BrowseFilterViewController type
                2. The presented browse filter controller was submitted (and not cancelled)
                3. The child view controller's (navigation controller) child view controller at index 0
                (every navigation controller should normally just have one child view controller) can be
                casted to the BrowseViewController type
             */
            if let presentedBrowseFilterController = presentedViewController as? BrowseFilterViewController,
                presentedBrowseFilterController.wasSubmitted,
                let presentingBrowseViewController = childViewController.childViewControllers[0] as? BrowseViewController {
                
                /*
                    If everything evaluates to true, the browse parameters should be set
                    and depending on the "activated" series type button a new series list
                    with the appropriate type should be requested
                 */
                setBrowseParameters()
                presentingBrowseViewController.showsAllAvailableSeriesItems = false
                
                if presentedBrowseFilterController.seriesTypeButtonManga.isOn {
                    presentingBrowseViewController.seriesType = .manga
                    UserDefaults.standard.set("manga", forKey: "browseSeriesType")
                    presentingBrowseViewController.getSeriesList()
                } else {
                    presentingBrowseViewController.seriesType = .anime
                    UserDefaults.standard.set("anime", forKey: "browseSeriesType")
                    presentingBrowseViewController.getSeriesList()
                }
            }
            
            /*
                Try to get the presenting browse view controller and set its
                series collection view's alpha value back to 1.0
             */
            if let presentingBrowseViewController = childViewController.childViewControllers[0] as? BrowseViewController {
                UIView.animate(withDuration: 0.5) {
                    presentingBrowseViewController.seriesCollectionView.alpha = 1.0
                }
            }
        }
    }
    
    // This method sets the data source's browse parameters
    func setBrowseParameters() {
        typealias BrowseParameterKey = AniListConstant.ParameterKey.Browse
        
        /*
            At first, the current shared data source's browse parameters
            should be set to an empty dictionary so that it's guaranteed
            that only the currently set filters are set browse parameters
         */
        DataSource.shared.browseParameters = [String:Any]()
        
        /*
            Iterate over all filter names and values in the data source's
            selectedBrowseFilters property
         */
        for (filterName, filterValues) in DataSource.shared.selectedBrowseFilters {
            
            guard let filterValues = filterValues else {
                print("No filter values available")
                break
            }
            
            /*
                If the filter name is "Genres" an empty array of strings should
                be created and filled with all dictionary values in the filter
                values.
             
                Afterwards a genre parameter value should be created
                and set in the shared data source. After that the loop can
                continue to its next iteration.
             
                Currently this only has to be done for the "Genres" filter
                as it's the only one that can have multiple selected filters
             */
            if filterName == "Genres" {
                var genres = [String]()
                for (_, filterValue) in filterValues {
                    genres.append(filterValue)
                }
                let genreParameterValue = createGenreParameterString(fromGenres: genres)
                DataSource.shared.set(parameterValue: genreParameterValue, forBrowseParameterWithName: BrowseParameterKey.genres)
                continue
            }
            
            /*
                Iterate over all filter values, then switch over the filter
                names and set the appropriate parameter values in the shared
                data source
             */
            for (_, filterValue) in filterValues {
                switch filterName {
                case "Sort By":
                    DataSource.shared.set(parameterValue: "\(filterValue)-desc", forBrowseParameterWithName: BrowseParameterKey.sort)
                case "Season":
                    DataSource.shared.set(parameterValue: filterValue, forBrowseParameterWithName: BrowseParameterKey.season)
                case "Status":
                    DataSource.shared.set(parameterValue: filterValue, forBrowseParameterWithName: BrowseParameterKey.status)
                case "Type":
                    DataSource.shared.set(parameterValue: filterValue, forBrowseParameterWithName: BrowseParameterKey.type)
                case "Year":
                    DataSource.shared.set(parameterValue: filterValue, forBrowseParameterWithName: BrowseParameterKey.year)
                default:
                    print("Unknown filter name \(filterName)")
                    break
                }
            }
            let selectedBrowseFiltersDictionaryData = NSKeyedArchiver.archivedData(withRootObject: DataSource.shared.selectedBrowseFilters)
            UserDefaults.standard.set(selectedBrowseFiltersDictionaryData, forKey: "selectedBrowseFilters")
        }
    }
    
    /*
        This function creates a parameter string by taking in an array of genre
        strings and connecting all genres with a separating comma
     */
    func createGenreParameterString(fromGenres genres: [String]) -> String {
        var genreParameterString = ""
        for genre in genres {
            if genreParameterString == "" {
                genreParameterString = genre
            } else {
                genreParameterString = "\(genreParameterString),\(genre)"
            }
        }
        return genreParameterString
    }
    
}
