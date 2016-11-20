//
//  AniManagerViewController.swift
//  AniManager
//
//  Created by Tobias Helmrich on 19.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class AniManagerViewController: UIViewController {

    fileprivate var errorMessageView = UIView()
    
    // This method sets up the error message view by configuring its properties as well as
    // adding a cancel button and a label that contains the error message's text and sets
    // all necessary constraints. After the error message view is set up, it's displayed.
    func showError(withMessage message: String) {
        
        // Set up the error message view:
        // - Hide it and set its background
        errorMessageView.isHidden = true
        errorMessageView.backgroundColor = UIColor(red: 1, green: 82 / 255, blue: 82 / 255, alpha: 1)
        
        // - Add it to the view controller's main view as a subview and set its constraints
        view.addSubview(errorMessageView)
        errorMessageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: errorMessageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60),
            NSLayoutConstraint(item: errorMessageView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: errorMessageView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: errorMessageView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        // Add a cancel button to the error message view
        let cancelButton = UIButton()
        cancelButton.setImage(#imageLiteral(resourceName: "CancelCross"), for: .normal)
        errorMessageView.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                NSLayoutConstraint(item: cancelButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 15),
                NSLayoutConstraint(item: cancelButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 15),
                NSLayoutConstraint(item: cancelButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -15),
                NSLayoutConstraint(item: cancelButton, attribute: .top, relatedBy: .equal, toItem: errorMessageView, attribute: .top, multiplier: 1, constant: 15)
            ])
        
        // Add a target-action to the button that calls the hideError method when
        // the cancel button is touched
        cancelButton.addTarget(self, action: #selector(hideError), for: .touchUpInside)

        // Add an error label that displays the error message's text
        let errorLabel = UILabel()
        errorLabel.numberOfLines = 2
        errorLabel.font = UIFont(name: "Lato-Light", size: 14)
        errorLabel.textColor = .white
        errorLabel.text = message
        errorLabel.textAlignment = .center
        errorMessageView.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: errorLabel, attribute: .centerX, relatedBy: .equal, toItem: errorMessageView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: errorLabel, attribute: .centerY, relatedBy: .equal, toItem: errorMessageView, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: errorLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: view.bounds.width - 85),
            NSLayoutConstraint(item: errorLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 34)
            ])
        
        // Show the error message view
        errorMessageView.isHidden = false
        
    }
    
    func hideError() {
        errorMessageView.isHidden = true
    }
    
}
