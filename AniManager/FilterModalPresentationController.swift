//
//  FilterModalPresentationController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 28.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class FilterModalPresentationController: UIPresentationController {
    
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
            if let presentedBrowseFilterController = presentedViewController as? BrowseFilterViewController,
                presentedBrowseFilterController.wasSubmitted,
                let presentingBrowseViewController = childViewController.childViewControllers[0] as? BrowseViewController {
                if presentedBrowseFilterController.seriesTypeButtonManga.isOn {
                    presentingBrowseViewController.seriesType = .manga
                    presentingBrowseViewController.getSeriesList()
                } else {
                    presentingBrowseViewController.seriesType = .anime
                    presentingBrowseViewController.getSeriesList()
                }
            }
            
            if let presentingBrowseViewController = childViewController.childViewControllers[0] as? BrowseViewController {
                UIView.animate(withDuration: 0.5) {
                    presentingBrowseViewController.seriesCollectionView.alpha = 1.0
                }
            }
        }
    }
}
