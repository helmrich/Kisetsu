//
//  VideoTableViewCell.swift
//  AniManager
//
//  Created by Tobias Helmrich on 05.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit
import WebKit

class VideoTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    let videoWebView = WKWebView()

    
    // MARK: - Initializer
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Configure the video web view
        videoWebView.backgroundColor = Style.Color.Background.videoWebView
        videoWebView.scrollView.backgroundColor = Style.Color.Background.videoWebView
        videoWebView.scrollView.isScrollEnabled = false
        
        // Configure the title label and set its constraints
        let titleLabel = TableViewCellTitleLabel(withTitle: "Video")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addConstraints([
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 15.0),
            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 15.0)
            ])
        
        // Set the video web view's constraints
        videoWebView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(videoWebView)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: videoWebView, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1.0, constant: 15.0),
            NSLayoutConstraint(item: videoWebView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -15.0),
            NSLayoutConstraint(item: videoWebView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300.0),
            NSLayoutConstraint(item: videoWebView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: videoWebView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        ])
    }

}
