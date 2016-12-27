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
                DataSource.shared.setBrowseParameters()
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
}
