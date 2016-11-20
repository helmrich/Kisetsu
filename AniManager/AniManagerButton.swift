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

    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
            ])
    }
    
    func setActivityIndicator(active: Bool) {
        if active {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            setTitleColor(titleColor(for: .normal)!.withAlphaComponent(0), for: .normal)
            backgroundColor = backgroundColor?.withAlphaComponent(0.8)
            isEnabled = false
        } else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            setTitleColor(titleColor(for: .normal)!.withAlphaComponent(1), for: .normal)
            backgroundColor = backgroundColor?.withAlphaComponent(1)
            isEnabled = true
        }
    }
    
}
