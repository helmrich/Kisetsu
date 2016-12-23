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
            NSLayoutConstraint(item: cancelButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: cancelButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 10)
        ])
        
        /*
             Add a target-action to the button that calls the hideError method when
             the cancel button is touched
         */
        cancelButton.addTarget(self, action: #selector(hideError), for: .touchUpInside)
        
        // Add an error label that displays the error message's text
        errorLabel.numberOfLines = 2
        errorLabel.font = UIFont(name: Constant.FontName.mainLight, size: 14)
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
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - Functions
    
    func showError(withMessage message: String) {
        DispatchQueue.main.async {
            self.errorLabel.text = "Error: \(message)"
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 1
            })
        }
    }
    
    func hideError() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 0
            })
        }
    }

}


// MARK: - UIViewController extension

extension UIViewController {
    /*
        This method adds an error message view at the bottom of a view
        controller's main view
     */
    func addErrorMessageViewToBottomOfView(withOffsetToBottom bottomOffset: CGFloat = 0, errorMessageView: ErrorMessageView) {
        view.addSubview(errorMessageView)
        errorMessageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: errorMessageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60),
            NSLayoutConstraint(item: errorMessageView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: errorMessageView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: errorMessageView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: bottomOffset)
            ])
    }
}
