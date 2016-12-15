//
//  AniListClient.swift
//  AniManager
//
//  Created by Tobias Helmrich on 21.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

class AniListClient {
    
    // Singleton
    static let shared = AniListClient()
    fileprivate init() {}
    
    var authorizationCode: String? = nil
    
}
