//
//  BannerView.swift
//  AniManager
//
//  Created by Tobias Helmrich on 01.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class BannerView: UIView {
    
    /*
        The parallax effect implemented in the banner view was inspired by
        the ParallaxAutoLayoutDemo GitHub repo: https://github.com/runmad/ParallaxAutoLayoutDemo
     */

    // MARK: - Properties
    
    var heightLayoutConstraint = NSLayoutConstraint()
    var bottomLayoutConstraint = NSLayoutConstraint()
    var overlayHeightLayoutConstraint = NSLayoutConstraint()
    var overlayBottomLayoutConstraint = NSLayoutConstraint()
    
    var containerView = UIView()
    var containerLayoutConstraint = NSLayoutConstraint()
    
    var imageView = UIImageView()
    
    let dismissButton = UIButton()
    let favoriteButton = UIButton()
    
    let seriesTitleLabel = UILabel()
    let seriesReleaseYearLabel = UILabel()
    
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Configure the container view and set its constraints
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["containerView":containerView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[containerView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["containerView":containerView]))
        containerLayoutConstraint = NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0.0)
        addConstraint(containerLayoutConstraint)
        
        // Configure the image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.aniManagerGray
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.0
        containerView.addSubview(imageView)
        containerView.addConstraints([
            NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: 0.0)
            ])
        
        // Create and configure the image overlay view
        let imageOverlayView = UIView()
        imageOverlayView.translatesAutoresizingMaskIntoConstraints = false
        imageOverlayView.backgroundColor = UIColor.aniManagerBlack.withAlphaComponent(0.7)
        imageOverlayView.clipsToBounds = true
        containerView.addSubview(imageOverlayView)
        containerView.addConstraints([
                NSLayoutConstraint(item: imageOverlayView, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: imageOverlayView, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: 0.0)
            ])

        
        // Add the dismiss and favorite button
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.setImage(#imageLiteral(resourceName: "CancelCross"), for: .normal)
        containerView.addSubview(dismissButton)
        containerView.addConstraints([
                NSLayoutConstraint(item: dismissButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25.0),
                NSLayoutConstraint(item: dismissButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25.0),
                NSLayoutConstraint(item: dismissButton, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -20.0),
                NSLayoutConstraint(item: dismissButton, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: 15.0)
            ])
        
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.setImage(#imageLiteral(resourceName: "HeartIcon"), for: .normal)
        containerView.addSubview(favoriteButton)
        containerView.addConstraints([
            NSLayoutConstraint(item: favoriteButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25.0),
            NSLayoutConstraint(item: favoriteButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25.0),
            NSLayoutConstraint(item: favoriteButton, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 20.0),
            NSLayoutConstraint(item: favoriteButton, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: 15.0)
            ])

        
        /*
            Set the series title and release year labels' properties
            and create a stack view with them
         */
        seriesTitleLabel.font = UIFont(name: Constant.FontName.mainBlack, size: 24.0)
        seriesTitleLabel.textColor = .white
        seriesTitleLabel.numberOfLines = 3
        seriesReleaseYearLabel.font = UIFont(name: Constant.FontName.mainLight, size: 14.0)
        seriesReleaseYearLabel.textColor = .white
        let stackView = UIStackView(arrangedSubviews: [
            seriesTitleLabel,
            seriesReleaseYearLabel
            ])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        containerView.addConstraints([
                NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1.0, constant: -15.0),
                NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: -10.0)
            ])
        
        
        bottomLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        overlayBottomLayoutConstraint = NSLayoutConstraint(item: imageOverlayView, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        heightLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: containerView, attribute: .height, multiplier: 1.0, constant: 0.0)
        overlayHeightLayoutConstraint = NSLayoutConstraint(item: imageOverlayView, attribute: .height, relatedBy: .equal, toItem: containerView, attribute: .height, multiplier: 1.0, constant: 0.0)
        containerView.addConstraints([
                bottomLayoutConstraint,
                overlayBottomLayoutConstraint,
                heightLayoutConstraint,
                overlayHeightLayoutConstraint
            ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        containerLayoutConstraint.constant = scrollView.contentInset.top
        let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        containerView.clipsToBounds = offsetY <= 0
        bottomLayoutConstraint.constant = offsetY >= 0 ? 0 : -offsetY / 2
        overlayBottomLayoutConstraint.constant = offsetY >= 0 ? 0 : -offsetY / 2
        heightLayoutConstraint.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
        overlayHeightLayoutConstraint.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
    }

}
