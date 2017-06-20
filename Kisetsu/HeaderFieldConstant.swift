//
//  HeaderFieldConstant.swift
//  AniManager
//
//  Created by Tobias Helmrich on 21.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

extension HeaderFieldConstant {
    struct HeaderFieldName {
        static let authorization = "Authorization"
        static let contentType = "Content-Type"
    }
    
    struct HeaderFieldValue {
        static let authorizationAccessToken = "Bearer access_token"
        static let contentType = "application/x-www-form-urlencoded"
        static let contentTypeJson = "application/json"
    }
}
