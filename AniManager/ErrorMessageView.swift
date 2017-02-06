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
    
    var topConstraint: NSLayoutConstraint!
    var bottomOffset: CGFloat!
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.alpha = 0.0
        self.backgroundColor = UIColor(red: 1, green: 82 / 255, blue: 82 / 255, alpha: 1)
        
        // Add an error label that displays the error message's text
        errorLabel.numberOfLines = 2
        errorLabel.font = UIFont(name: Constant.FontName.mainLight, size: 14.0)
        errorLabel.textColor = .white
        errorLabel.textAlignment = .center
        self.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: errorLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: errorLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: errorLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 290.0),
            NSLayoutConstraint(item: errorLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 34.0)
            ])
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - Functions
    
    /*
     This method adds an error message view at the bottom of a view
     (usually a view controller's main view). It has to be called before
     calling any other methods of the error message view (such as show,
     hide and showAndHide)
     */
    func addToBottom(of view: UIView, withOffsetToBottom bottomOffset: CGFloat = 0.0) {
        
        self.bottomOffset = bottomOffset
        
        topConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        
        view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60.0),
                NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0),
                topConstraint
            ])
    }
    
    func showAndHide(withMessage message: String) {
        DispatchQueue.main.async {
            self.errorLabel.text = "Error: \(message)"
            UIView.animate(withDuration: 0.33, animations: {
                self.alpha = 1.0
                self.topConstraint.constant = -(60.0 + self.bottomOffset)
                self.superview!.layoutIfNeeded()
            })
            
            UIView.animate(withDuration: 0.33, delay: 5.33, options: [], animations: {
                self.alpha = 0.0
                self.topConstraint.constant = 0.0
                self.superview!.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func show(withMessage message: String) {
        DispatchQueue.main.async {
            self.errorLabel.text = "Error: \(message)"
            UIView.animate(withDuration: 0.33, animations: {
                self.alpha = 1.0
                self.topConstraint.constant = -(60.0 + self.bottomOffset)
                self.superview!.layoutIfNeeded()
            })
        }
    }
    
    func hide() {
        DispatchQueue.main.async {
            self.layer.removeAllAnimations()
            
            UIView.animate(withDuration: 0.33, animations: {
                self.alpha = 0.0
                self.topConstraint.constant = 0.0
                self.superview!.layoutIfNeeded()
            })
        }
    }
    
}
