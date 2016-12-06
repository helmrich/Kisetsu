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
    
    let videoWebView = WKWebView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        videoWebView.backgroundColor = .aniManagerBlack
        videoWebView.scrollView.backgroundColor = .aniManagerBlack
        videoWebView.scrollView.isScrollEnabled = false
        
        let titleLabel = TableViewCellTitleLabel()
        titleLabel.text = "Video"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addConstraints([
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 15.0),
            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 15.0)
            ])
        
        videoWebView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(videoWebView)
        addConstraints([
                NSLayoutConstraint(item: videoWebView, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1.0, constant: 15.0),
                NSLayoutConstraint(item: videoWebView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -15.0),
                NSLayoutConstraint(item: videoWebView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 230.0),
                NSLayoutConstraint(item: videoWebView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: videoWebView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0)
            ])
        
        
    }

}
