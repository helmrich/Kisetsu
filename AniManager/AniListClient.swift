//
//  AniListClient.swift
//  AniManager
//
//  Created by Tobias Helmrich on 21.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

class AniListClient {
    
    static let shared = AniListClient()
    var authorizationCode: String? = nil
    
    fileprivate init() {}
    
    
    // MARK: - Helper methods
    static func createAniListUrl(withPath path: String, andParameters parameters: [String:Any]) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = AniListConstant.URL.scheme
        urlComponents.host = AniListConstant.URL.host
        urlComponents.path = "\(AniListConstant.URL.basePath)\(path)"
        
        var queryItems = [URLQueryItem]()
        for (parameterName, parameterValue) in parameters {
            let queryItem = URLQueryItem(name: parameterName, value: "\(parameterValue)")
            queryItems.append(queryItem)
        }
        
        urlComponents.queryItems = queryItems
        
        return urlComponents.url
        
    }
}
