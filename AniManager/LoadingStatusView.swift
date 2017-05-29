//
//  LoadingStatusView.swift
//  AniManager
//
//  Created by Tobias Helmrich on 13.05.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import UIKit

class LoadingStatusView: UIView {
    
    // MARK: - Properties
    
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        alpha = 0.0
        
        backgroundColor = UIColor.aniManagerBlack.withAlphaComponent(0.6)
        
        activityIndicatorView.startAnimating()
        addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: activityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
            ])
        
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - Functions
    
    func set(visible: Bool) {
        DispatchQueue.main.async {
            guard visible == true else {
                UIView.animate(withDuration: 0.5) {
                    self.alpha = 0.0
                }
                return
            }
            UIView.animate(withDuration: 0.5) {
                self.alpha = 1.0
            }
        }
    }
    
    func setVisibilityDependingOnNetworkStatus() {
        set(visible: NetworkActivityManager.shared.numberOfActiveConnections > 0)
    }
}

