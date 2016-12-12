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
            When the modal will be dismissed the presenting BrowseViewController's
            series collection view's alpha value should be reset to 1
         */
        for childViewController in (self.presentingViewController as! UITabBarController).childViewControllers {
            if let presentingBrowseViewController = childViewController.childViewControllers[0] as? BrowseViewController {
                UIView.animate(withDuration: 0.5) {
                    presentingBrowseViewController.seriesCollectionView.alpha = 1.0
                }
            }
        }
    }
}
