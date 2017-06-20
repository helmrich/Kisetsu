//
//  AniManagerButton.swift
//  AniManager
//
//  Created by Tobias Helmrich on 18.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation
import UIKit

class AniManagerButton: UIButton {

    // MARK: - Properties
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupViews()
    }
    
    
    // MARK: - Methods
    
    func setupViews() {
        /*
            Set the button layer's corner radius and background color
            and add a constraint for its height
         */
        layer.cornerRadius = 2.0
        backgroundColor = Style.Color.Background.aniManagerButton
        setTitleColor(Style.Color.Text.aniManagerButton, for: .normal)
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50.0))
        
        /*
            Add the activity indicator to the button as a subview
            and set its constraints
         */
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
            ])
        activityIndicator.alpha = 0
        
        // Add actions that handle the button's appearance when it's tapped
        addTarget(self, action: #selector(setTouchDownAppearance), for: .touchDown)
        addTarget(self, action: #selector(setTouchUpAppearance), for: [.touchUpInside, .touchUpOutside])
    }
    
    /*
        This method configures the button's activity indicator's appearance
        based on whether the activity indicator should be active or not
     */
    func setActivityIndicator(active: Bool) {
        if active {
            set(enabled: false)
            UIView.animate(withDuration: 0.25, animations: {
                self.setTitleColor(self.titleColor(for: .normal)?.withAlphaComponent(0.0), for: .normal)
                self.activityIndicator.alpha = 1
            })
            activityIndicator.startAnimating()
        } else {
            set(enabled: true)
            UIView.animate(withDuration: 0.25, animations: {
                self.activityIndicator.alpha = 0
            })
            activityIndicator.stopAnimating()
        }
    }
    
    /*
        These methods should be used to set the button's appearance
        when it's tapped
     */
    func setTouchDownAppearance() {
        setTitleColor(titleColor(for: .normal)?.withAlphaComponent(0.6), for: .normal)
        backgroundColor = backgroundColor?.withAlphaComponent(0.8)
    }
    
    func setTouchUpAppearance() {
        setTitleColor(titleColor(for: .normal)?.withAlphaComponent(1.0), for: .normal)
        backgroundColor = backgroundColor?.withAlphaComponent(1.0)
    }
    
    /*
        This method sets the button's appearance to an enabled or disabled
        state by enabling/disabling it and changing the background and title
        color to an appropriate color
     */
    func set(enabled: Bool) {
        if enabled {
            UIView.animate(withDuration: 0.25, animations: {
                self.setTitleColor(self.titleColor(for: .normal)!.withAlphaComponent(1.0), for: .normal)
                self.backgroundColor = self.backgroundColor?.withAlphaComponent(1.0)
            })
            isEnabled = true
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.6)
            })
            isEnabled = false
        }
    }
    
}
