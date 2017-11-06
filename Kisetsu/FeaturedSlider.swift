//
//  FeaturedSlider.swift
//  AniManager
//
//  Created by Tobias Helmrich on 19.05.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import UIKit
import Kingfisher

class FeaturedSlider: UIView {
    
    // MARK: - Properties
    
    var timer: Timer?
    
    var seriesList: [Series] = [Series]()
    
    let imageView = UIImageView()
    let overlayView = UIView()
    let titleLabel = UILabel()
    let pageControl = UIPageControl()
    var currentlySelectedSeries: Series?
    var currentSeriesIndex: Int? {
        didSet {
            guard let currentSeriesIndex = currentSeriesIndex else {
                currentlySelectedSeries = nil
                return
            }
            
            guard currentSeriesIndex < seriesList.count else {
                currentlySelectedSeries = nil
                return
            }
            
            currentlySelectedSeries = seriesList[currentSeriesIndex]
        }
    }
    
    var isAutomaticSlidingEnabled = false {
        didSet {
            setupAutomaticSliding()
        }
    }
    var automaticSlidingTimeInterval = 4.0
    
    
    // MARK: - Lifecycle Methods
    
    override func layoutSubviews() {
        guard seriesList.count > 0 else {
            return
        }
        
        /*
            If no current series index is set, set the current series index
            to the index of the series list's middle item
         */
        if currentSeriesIndex == nil {
            currentSeriesIndex = Int((Double(seriesList.count) / 2.0))
        }
        
        guard let currentSeriesIndex = currentSeriesIndex else {
            return
        }
        
        // Setup views
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
//        imageView.alpha = 0.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        overlayView.backgroundColor = .aniManagerBlack
        overlayView.alpha = 0.6
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlayView)
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: Constant.FontName.mainBlack, size: 30.0)
        titleLabel.numberOfLines = 3
//        titleLabel.alpha = 0.0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        pageControl.isUserInteractionEnabled = false
        pageControl.numberOfPages = seriesList.count
        pageControl.currentPage = currentSeriesIndex
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pageControl)
        
        // Setup constraints
        
        NSLayoutConstraint.activate([
            // Image View
            NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            // Title Label
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 20.0),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -20.0),
            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 20.0),
            // Overlay View
            NSLayoutConstraint(item: overlayView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: overlayView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: overlayView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: overlayView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            // Page Control
            NSLayoutConstraint(item: pageControl, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: pageControl, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -10.0)
        ])
        
        setupImageView()
        setupTitleLabel()
        
        /*
            Create two swipe gesture recognizers for left and right swipes
            and add them to the featured slider
         */
        let featuredSliderLeftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(featuredSliderSwipeOccurred))
        featuredSliderLeftSwipeGestureRecognizer.direction = .left
        self.addGestureRecognizer(featuredSliderLeftSwipeGestureRecognizer)
        
        let featuredSliderRightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(featuredSliderSwipeOccurred))
        featuredSliderRightSwipeGestureRecognizer.direction = .right
        self.addGestureRecognizer(featuredSliderRightSwipeGestureRecognizer)
    }
    
    // MARK: - Functions
    
    /*
        This function should be called after the value of the
        isAutomaticSlidingEnabled property is altered.
        - true: A timer is started which calls the showNextFeaturedTitle
        function repeatedly after a certain time interval and assigned
        to the timer property
        - false: If a timer was assigned to the timer property before
        this timer is invalidated and the property is reset to nil
     */
    func setupAutomaticSliding() {
        if isAutomaticSlidingEnabled {
            timer = Timer.scheduledTimer(timeInterval: automaticSlidingTimeInterval, target: self, selector: #selector(showNextFeaturedTitle), userInfo: nil, repeats: true)
        } else {
            if let timer = timer {
                timer.invalidate()
            }
            timer = nil
        }
    }
    
    func featuredSliderSwipeOccurred(sender: UISwipeGestureRecognizer) {
        isAutomaticSlidingEnabled = false
        isAutomaticSlidingEnabled = true
        if sender.direction == .left {
            showFeaturedTitle(inOrder: .next)
        } else if sender.direction == .right {
            showFeaturedTitle(inOrder: .previous)
        }
    }
    
    func showNextFeaturedTitle() {
        showFeaturedTitle(inOrder: .next)
    }
    
    /*
        This function shows another featured title based on a specified
        order (previous or next) in which it appears in the series list
        array compared to the currently showing series title
     */
    func showFeaturedTitle(inOrder order: SliderOrder) {
        guard currentSeriesIndex != nil else {
            return
        }
        
        var mutableSeriesIndex = currentSeriesIndex!
        
        switch order {
        case .previous:
            mutableSeriesIndex -= 1
            if mutableSeriesIndex < 0 {
                mutableSeriesIndex = seriesList.count - 1
            }
        case .next:
            mutableSeriesIndex += 1
            if mutableSeriesIndex >= seriesList.count {
                mutableSeriesIndex = 0
            }
        }
        
        self.currentSeriesIndex = mutableSeriesIndex
        setFeaturedTitle()
    }
    
    /*
        This function sets the featured slider's subviews'
        variable properties to the current series' values
        (image, title) and adjusts the page control's currentPage
        property
     */
    func setFeaturedTitle() {
        guard let currentSeriesIndex = currentSeriesIndex,
            currentSeriesIndex < seriesList.count,
            currentSeriesIndex >= 0 else {
                return
        }
        
        UIView.transition(with: imageView, duration: 0.5, options: .transitionCrossDissolve, animations: { 
            self.setupImageView()
            self.setupTitleLabel()
        }, completion: nil)
        UIView.animate(withDuration: 1.5) {
            self.pageControl.currentPage = currentSeriesIndex
        }
    }
    
    func setupImageView() {
        guard let currentlySelectedSeries = currentlySelectedSeries else {
            return
        }
        
        if let imageBannerURLString = currentlySelectedSeries.imageBannerURLString,
            let imageBannerURL = URL(string: imageBannerURLString) {
            DispatchQueue.main.async {
                self.imageView.kf.setImage(with: imageBannerURL, placeholder: UIImage.with(color: .aniManagerBlack, andSize: self.imageView.frame.size), options: [.transition(.fade(0.5))], progressBlock: nil, completionHandler: nil)
            }
        }
    }
    
    func setupTitleLabel() {
        guard let currentlySelectedSeries = currentlySelectedSeries else {
            return
        }
        
        DispatchQueue.main.async {
            self.titleLabel.text = currentlySelectedSeries.titleForSelectedTitleLanguageSetting
        }
    }
    
    func setBackgroundColor() {
        backgroundColor = Style.Color.Background.featuredSlider
    }
}

extension FeaturedSlider {
    enum SliderOrder {
        case previous, next
    }
}
