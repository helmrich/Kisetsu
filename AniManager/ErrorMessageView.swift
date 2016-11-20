//
//  ErrorMessageView.swift
//  AniManager
//
//  Created by Tobias Helmrich on 20.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class ErrorMessageView: UIView {

    // MARK: - Properties
    
    let cancelButton = UIButton()
    let errorLabel = UILabel()
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.alpha = 0
        self.backgroundColor = UIColor(red: 1, green: 82 / 255, blue: 82 / 255, alpha: 1)
        
        // Add a cancel button to the error message view
        cancelButton.setImage(#imageLiteral(resourceName: "CancelCross"), for: .normal)
        self.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: cancelButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 15),
            NSLayoutConstraint(item: cancelButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 15),
            NSLayoutConstraint(item: cancelButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -15),
            NSLayoutConstraint(item: cancelButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 15)
        ])
        
        // Add a target-action to the button that calls the hideError method when
        // the cancel button is touched
        cancelButton.addTarget(self, action: #selector(hideError), for: .touchUpInside)
        
        // Add an error label that displays the error message's text
        errorLabel.numberOfLines = 2
        errorLabel.font = UIFont(name: "Lato-Light", size: 14)
        errorLabel.textColor = .white
        errorLabel.textAlignment = .center
        self.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: errorLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: errorLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: errorLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 290),
            NSLayoutConstraint(item: errorLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 34)
        ])
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Methods
    
    func showError(withMessage message: String) {
        errorLabel.text = "Error: \(message)"
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1
        })
    }
    
    func hideError() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        })
    }

}
