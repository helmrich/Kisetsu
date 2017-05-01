//
//  ViewControllerLoadingStatusExtension.swift
//  AniManager
//
//  Created by Tobias Helmrich on 01.05.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showLoadingStatus() -> UIView {
        let loadingOverlayView = UIView(frame: view.frame)
        loadingOverlayView.alpha = 0.0
        loadingOverlayView.backgroundColor = UIColor.aniManagerBlack.withAlphaComponent(0.7)
        view.addSubview(loadingOverlayView)
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.center = view.center
        activityIndicatorView.startAnimating()
        loadingOverlayView.addSubview(activityIndicatorView)
        
        UIView.animate(withDuration: 0.5) {
            loadingOverlayView.alpha = 1.0
        }
        return loadingOverlayView
    }
    
    func hideLoadingStatus(of loadingView: UIView) {
        UIView.animate(withDuration: 0.5, animations: {
            loadingView.alpha = 0.0
        }, completion: { _ in
            loadingView.removeFromSuperview()
        })
    }
}
