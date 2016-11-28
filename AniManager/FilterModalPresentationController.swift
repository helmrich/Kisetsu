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
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        /*
            When the modal was presented a tap gesture recognizer
            should be added to the presentation controller with
            an action that dismisses the modally presented view 
            controller
        */
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissModalController))
        containerView?.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func dismissalTransitionWillBegin() {
        /*
            When the modal will be dismissed the presenting BrowseViewController's
            series collection view's alpha value should be reset to 1
         */
        UIView.animate(withDuration: 0.5) {
            ((self.presentingViewController.childViewControllers[0] as! UITabBarController).selectedViewController as! BrowseViewController).seriesCollectionView.alpha = 1
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        /*
            When the dismissal of the modal ends the tap gesture recognizer
            should be removed from it
         */
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissModalController))
        containerView?.removeGestureRecognizer(tapGestureRecognizer)
    }
    
    func dismissModalController() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
