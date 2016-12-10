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
