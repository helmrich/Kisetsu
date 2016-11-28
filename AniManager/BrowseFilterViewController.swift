//
//  BrowseFilterViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 28.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class BrowseFilterViewController: UIViewController {

    // MARK: - Properties
    
    var presentingBrowseViewController: BrowseViewController?
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    
    // MARK: - Outlets and Actions
    
    // MARK: - Outlets
    
    
    // MARK: - Actions
    
    @IBAction func applyFilters() {
        // TODO: Save selected filters as parameters in BrowseViewController
        // and request a new list of series.
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        /*
            This gesture recognizer is added in order to prevent the filter modal
            from being dismissed because of the FilterModalPresentationController's
            tap gesture recognizer. This way it's only dismissed when there is a tap
            outside of the BrowseFilterViewController.
         */
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: nil)
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    

}
