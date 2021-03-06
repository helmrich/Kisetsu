//
//  AniListConstant.swift
//  AniManager
//
//  Created by Tobias Helmrich on 20.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

typealias ParameterConstant = AniListConstant
typealias HeaderFieldConstant = AniListConstant
typealias PathConstant = AniListConstant
typealias ResponseConstant = AniListConstant
typealias PayloadConstant = AniListConstant

struct AniListConstant {
    struct Account {
        static let clientId = "tobe-pikrk"
        static let clientSecret = "OUlu5I6VyOvs7jaTLJgS4h"
    }
    
    struct URL {
        static let scheme = "https"
        static let host = "anilist.co"
        static let basePath = "/api/"
    }
}
