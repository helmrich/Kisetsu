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
    
    // MARK: - Methods
    
    func getAccessToken(withAuthorizationCode: Bool = false, withRefreshToken: Bool = false, completionHandlerForTokens: @escaping (_ accessToken: AccessToken?, _ refreshToken: String?, _ errorMessage: String?) -> Void) {
        var parameters = [
            AniListConstant.ParameterKey.Authentication.clientId: AniListConstant.Account.clientId,
            AniListConstant.ParameterKey.Authentication.clientSecret: AniListConstant.Account.clientSecret
        ]
        
        if withAuthorizationCode == true,
        let authorizationCode = authorizationCode {
            parameters[AniListConstant.ParameterKey.Authentication.grantType] = AniListConstant.ParameterValue.Authentication.grantTypeAuthorizationCode
            parameters[AniListConstant.ParameterKey.Authentication.redirectUri] = AniListConstant.ParameterValue.Authentication.redirectUri
            parameters[AniListConstant.ParameterKey.Authentication.code] = authorizationCode
        }
        
        if withRefreshToken == true,
            let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") {
            parameters[AniListConstant.ParameterKey.Authentication.grantType] = AniListConstant.ParameterValue.Authentication.grantTypeRefreshToken
            parameters[AniListConstant.ParameterKey.Authentication.refreshToken] = refreshToken
        }
        
        guard let url = AniListClient.createAniListUrl(withPath: AniListConstant.Path.Authentication.accessToken, andParameters: parameters) else {
            completionHandlerForTokens(nil, nil, "Couldn't create AniList URL")
            return
        }
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard error == nil else {
                completionHandlerForTokens(nil, nil, error!.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
            statusCode >= 200 && statusCode <= 299 else {
                completionHandlerForTokens(nil, nil, "Unsuccessful response status code")
                return
            }
            
            guard let data = data else {
                completionHandlerForTokens(nil, nil, "Couldn't get data for access token")
                return
            }
            
            let jsonObject: [String:Any]
            do {
                jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
            } catch {
                completionHandlerForTokens(nil, nil, "Error when trying to deserialize JSON: \(error.localizedDescription)")
                return
            }
            
            guard let accessTokenValue = jsonObject[AniListConstant.ResponseKey.Authentication.accessToken] as? String,
                let tokenType = jsonObject[AniListConstant.ResponseKey.Authentication.tokenType] as? String,
                let expirationTimestamp = jsonObject[AniListConstant.ResponseKey.Authentication.expires] as? Int else {
                completionHandlerForTokens(nil, nil, "Couldn't parse access token values from JSON object")
                return
            }
            
            let accessToken = AccessToken(accessTokenValue: accessTokenValue, tokenType: tokenType, expirationTimestamp: expirationTimestamp)
            
            if withAuthorizationCode == true {
                guard let refreshTokenValue = jsonObject[AniListConstant.ResponseKey.Authentication.refreshToken] as? String else {
                    completionHandlerForTokens(nil, nil, "Couldn't parse refresh token value from JSON object")
                    return
                }
                completionHandlerForTokens(accessToken, refreshTokenValue, nil)
            } else {
                completionHandlerForTokens(accessToken, nil, nil)
            }
        }
        
        task.resume()
        
    }
    
    
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
