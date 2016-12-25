//
//  ActivityIndicatorViewExtension.swift
//  AniManager
//
//  Created by Tobias Helmrich on 25.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation
import UIKit

extension UIActivityIndicatorView {
    func startAnimatingAndFadeIn() {
        DispatchQueue.main.async {
            self.startAnimating()
            UIView.animate(withDuration: 0.25) {
                self.alpha = 1.0
            }
        }
    }
    
    func stopAnimatingAndFadeOut() {
        DispatchQueue.main.async {
            self.stopAnimating()
            UIView.animate(withDuration: 0.25) {
                self.alpha = 0.0
            }
        }
    }
}
