//
//  ExternalLink.swift
//  AniManager
//
//  Created by Tobias Helmrich on 04.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

struct ExternalLink {
    let siteName: String
    let siteURLString: String
    
    typealias ExternalLinkKey = AniListConstant.ResponseKey.ExternalLink
    
    init?(fromDictionary dictionary: [String:Any]) {
        guard let siteName = dictionary[ExternalLinkKey.site] as? String,
            let siteURLString = dictionary[ExternalLinkKey.url] as? String else {
                return nil
        }
        
        self.siteName = siteName
        self.siteURLString = siteURLString
    }
}
