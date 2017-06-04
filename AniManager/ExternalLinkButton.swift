//
//  ExternalLinkButton.swift
//  AniManager
//
//  Created by Tobias Helmrich on 09.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class ExternalLinkButton: AniManagerButton {

    // MARK: - Properties
    
    var siteURLString: String?

    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Add the openWebsite function to the button as an action
        addTarget(self, action: #selector(openWebsite), for: [.touchUpInside])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    // MARK: - Functions
    
    func openWebsite() {
        /*
            Check if the button's siteURLString property was set
            and create a string from the URL and open it in the
            device's browser if it was
         */
        if let urlString = siteURLString,
            let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}
