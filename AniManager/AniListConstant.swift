//
//  AniListConstant.swift
//  AniManager
//
//  Created by Tobias Helmrich on 20.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

struct AniListConstant {
    struct Account {
        static let clientId = "YOURCLIENTID"
        static let clientSecret = "YOURCLIENTSECRET"
    }
    
    struct URL {
        static let scheme = "https"
        static let host = "anilist.co"
        static let basePath = "/api/"
    }
    
    struct Path {
        struct Authentication {
            static let authorize = "auth/authorize"
            static let accessToken = "auth/access_token"
        }
    }
    
    struct ParameterKey {
        struct Authentication {
            static let grantType = "grant_type"
            static let clientId = "client_id"
            static let redirectUri = "redirect_uri"
            static let responseType = "response_type"
        }
    }
    
    struct ParameterValue {
        struct Authentication {
            static let grantType = "authorization_code"
            static let redirectUri = "AniManager://"
            static let responseType = "code"
        }
    }
    
}
