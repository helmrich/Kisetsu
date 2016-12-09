//
//  ExternalLinkButton.swift
//  AniManager
//
//  Created by Tobias Helmrich on 09.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class ExternalLinkButton: AniManagerButton {

    var siteUrlString: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 2.0
        backgroundColor = .aniManagerBlue
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50.0))
        
        addTarget(self, action: #selector(openWebsite), for: [.touchUpInside])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func openWebsite() {
        if let urlString = siteUrlString,
            let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}
