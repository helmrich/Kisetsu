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
    
    // MARK: - GET
    
    /*
        This method gets an access token (and also a refresh token if the authorization
        happens with an authorization code) by using either an authorization code (for the first
        authorization) or a refresh token
     */
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
        
        guard let url = createAniListUrl(withPath: AniListConstant.Path.Authentication.accessToken, andParameters: parameters) else {
            completionHandlerForTokens(nil, nil, "Couldn't create AniList URL")
            return
        }
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let errorMessage = self.checkDataTaskResponseForError(data: data, response: response, error: error) {
                completionHandlerForTokens(nil, nil, errorMessage)
                return
            }
            
            let data = data!
            
            guard let jsonObject = self.deserializeJson(fromData: data) else {
                completionHandlerForTokens(nil, nil, "Error when trying to deserialize JSON")
                return
            }
            
            guard let jsonDictionary = jsonObject as? [String:Any] else {
                completionHandlerForTokens(nil, nil, "Error when trying to cast JSON object to dictionary type")
                return
            }
            
            guard let accessTokenValue = jsonDictionary[AniListConstant.ResponseKey.Authentication.accessToken] as? String,
                let tokenType = jsonDictionary[AniListConstant.ResponseKey.Authentication.tokenType] as? String,
                let expirationTimestamp = jsonDictionary[AniListConstant.ResponseKey.Authentication.expires] as? Int else {
                completionHandlerForTokens(nil, nil, "Couldn't parse access token values from JSON object")
                return
            }
            
            let accessToken = AccessToken(accessTokenValue: accessTokenValue, tokenType: tokenType, expirationTimestamp: expirationTimestamp)
            
            if withAuthorizationCode == true {
                guard let refreshTokenValue = jsonDictionary[AniListConstant.ResponseKey.Authentication.refreshToken] as? String else {
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
    
    func getSeriesList(fromPage page: Int = 1, ofType seriesType: SeriesType, andParameters parameters: [String:Any], completionHandlerForSeriesList: @escaping (_ seriesList: [Series]?, _ errorMessage: String?) -> Void) {
        
        validateAccessToken { (errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForSeriesList(nil, errorMessage!)
                return
            }
            
            let replacingPairs = [
                AniListConstant.Path.Placeholder.seriesType: seriesType.rawValue
            ]
            
            let path = self.replacePlaceholders(inPath: AniListConstant.Path.SeriesGet.browse, withReplacingPairs: replacingPairs)
            
            var allParameters = parameters
            allParameters[AniListConstant.ParameterKey.Browse.page] = page
            
            guard let url = self.createAniListUrl(withPath: path, andParameters: allParameters) else {
                completionHandlerForSeriesList(nil, "Couldn't create AniList URL")
                return
            }
            
            let request = NSMutableURLRequest(url: url)
            request.addValue(AniListConstant.HeaderFieldValue.contentType, forHTTPHeaderField: AniListConstant.HeaderFieldName.contentType)
            request.addValue("Bearer \(UserDefaults.standard.string(forKey: "accessToken")!)", forHTTPHeaderField: AniListConstant.HeaderFieldName.authorization)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                
                if let errorMessage = self.checkDataTaskResponseForError(data: data, response: response, error: error) {
                    completionHandlerForSeriesList(nil, errorMessage)
                    return
                }
                
                let data = data!
                
                guard let jsonObject = self.deserializeJson(fromData: data) else {
                    completionHandlerForSeriesList(nil, "Couldn't deserialize data into a JSON object")
                    return
                }
                
                guard let rawSeriesList = jsonObject as? [[String:Any]] else {
                    completionHandlerForSeriesList(nil, "Couldn't cast JSON to array of dictionaries")
                    return
                }
                
                typealias seriesKey = AniListConstant.ResponseKey.Series
                
                var seriesList = [Series]()
                if seriesType.rawValue == SeriesType.anime.rawValue {
                    seriesList = seriesList as! [AnimeSeries]
                    for series in rawSeriesList {
                        if let animeSeries = AnimeSeries(fromDictionary: series) {
                            seriesList.append(animeSeries)
                        } else {
                            print("Couldn't create anime series")
                        }
                    }
                } else {
                    seriesList = seriesList as! [MangaSeries]
                    for series in rawSeriesList {
                        if let mangaSeries = MangaSeries(fromDictionary: series) {
                            seriesList.append(mangaSeries)
                        } else {
                            print("Couldn't create manga series")
                        }
                    }
                }
                
                completionHandlerForSeriesList(seriesList, nil)
                
            }
            
            task.resume()
            
        }
        
        
    }
    
    func getSingleSeries(ofType seriesType: SeriesType, withId id: Int, completionHandlerForSeries: @escaping (_ series: Series?, _ errorMessage: String?) -> Void) {
        
        validateAccessToken { (errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForSeries(nil, errorMessage!)
                return
            }
         
            let replacingPairs = [
                AniListConstant.Path.Placeholder.seriesType: seriesType.rawValue,
                AniListConstant.Path.Placeholder.id: "\(id)"
            ]
            
            let path = self.replacePlaceholders(inPath: AniListConstant.Path.SeriesGet.pageSeriesModel, withReplacingPairs: replacingPairs)
            
            guard let url = self.createAniListUrl(withPath: path, andParameters: [:]) else {
                completionHandlerForSeries(nil, "Couldn't create AniList URL")
                return
            }
            
            let request = NSMutableURLRequest(url: url)
            request.addValue(AniListConstant.HeaderFieldValue.contentType, forHTTPHeaderField: AniListConstant.HeaderFieldName.contentType)
            request.addValue("Bearer \(UserDefaults.standard.string(forKey: "accessToken")!)", forHTTPHeaderField: AniListConstant.HeaderFieldName.authorization)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                if let errorMessage = self.checkDataTaskResponseForError(data: data, response: response, error: error) {
                    completionHandlerForSeries(nil, errorMessage)
                    return
                }
                
                let data = data!
                
                guard let jsonObject = self.deserializeJson(fromData: data) else {
                    completionHandlerForSeries(nil, "Couldn't deserialize data into a JSON object")
                    return
                }
                
                guard let rawSeriesDictionary = jsonObject as? [String:Any] else {
                    completionHandlerForSeries(nil, "Couldn't cast JSON to dictionary")
                    return
                }
                print(jsonObject)
                typealias seriesKey = AniListConstant.ResponseKey.Series
                
                if seriesType.rawValue == SeriesType.anime.rawValue {
                    if let animeSeries = AnimeSeries(fromDictionary: rawSeriesDictionary) {
                        DataSource.shared.selectedSeries = animeSeries
                        completionHandlerForSeries(animeSeries, nil)
                        return
                    } else {
                        completionHandlerForSeries(nil, "Couldn't get Anime series")
                        return
                    }
                } else {
                    if let mangaSeries = MangaSeries(fromDictionary: rawSeriesDictionary) {
                        DataSource.shared.selectedSeries = mangaSeries
                        completionHandlerForSeries(mangaSeries, nil)
                        return
                    } else {
                        completionHandlerForSeries(nil, "Couldn't get Manga series")
                        return
                    }
                }
                
            }
            
            task.resume()
            
        }
        
    }
    
    func getPageModelCharacter(forCharacterId id: Int, completionHandlerForCharacterPageModel: @escaping (_ character: Character?, _ errorMessage: String?) -> Void) {
        
        
        validateAccessToken { (errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForCharacterPageModel(nil, errorMessage!)
                return
            }
         
            let replacingPairs = [
                AniListConstant.Path.Placeholder.id: "\(id)"
            ]
            let path = self.replacePlaceholders(inPath: AniListConstant.Path.CharacterGet.pageCharacterModel, withReplacingPairs: replacingPairs)
            guard let url = self.createAniListUrl(withPath: path, andParameters: [:]) else {
                completionHandlerForCharacterPageModel(nil, "Couldn't create AniList URL")
                return
            }
            
            let request = NSMutableURLRequest(url: url)
            request.addValue(AniListConstant.HeaderFieldValue.contentType, forHTTPHeaderField: AniListConstant.HeaderFieldName.contentType)
            request.addValue("Bearer \(UserDefaults.standard.string(forKey: "accessToken")!)", forHTTPHeaderField: AniListConstant.HeaderFieldName.authorization)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                if let errorMessage = self.checkDataTaskResponseForError(data: data, response: response, error: error) {
                    completionHandlerForCharacterPageModel(nil, errorMessage)
                    return
                }
                
                let data = data!
                
                guard let jsonObject = self.deserializeJson(fromData: data) else {
                    completionHandlerForCharacterPageModel(nil, "Couldn't deserialize data into a JSON object")
                    return
                }
                
                guard let characterDictionary = jsonObject as? [String:Any],
                    let character = Character(fromDictionary: characterDictionary) else {
                        completionHandlerForCharacterPageModel(nil, "Couldn't create character object from dictionary")
                        return
                }
                
                completionHandlerForCharacterPageModel(character, nil)
                
            }
            
            task.resume()

        }
        
        
        
        
    }

    // This method is used to get data for a single image from a specified URL string
    func getImageData(fromUrlString urlString: String, completionHandlerForImageData: @escaping (_ imageData: Data?, _ errorMessage: String?) -> Void) {
        guard let url = URL(string: urlString) else {
            completionHandlerForImageData(nil, "Couldn't create a URL from the provided URL string")
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let errorMessage = self.checkDataTaskResponseForError(data: data, response: response, error: error) {
                completionHandlerForImageData(nil, errorMessage)
                return
            }
            
            let data = data!
            
            completionHandlerForImageData(data, nil)
            
        }
        
        task.resume()
    }
    
    
    // MARK: - POST
    
    func favorite(seriesOfType type: SeriesType, withId id: Int, completionHandlerForFavoriting: @escaping (_ errorMessage: String?) -> Void) {
        let replacingPairs = [
            AniListConstant.Path.Placeholder.seriesType: type.rawValue
        ]
        
        let path = self.replacePlaceholders(inPath: AniListConstant.Path.SeriesPost.favourite, withReplacingPairs: replacingPairs)
        
        favorite(id: id, path: path, completionHandlerForFavoriting: completionHandlerForFavoriting)
    }

    func favorite(characterWithId id: Int, completionHandlerForFavoriting: @escaping (_ errorMessage: String?) -> Void) {
        let path = AniListConstant.Path.CharacterPost.favourite
        
        favorite(id: id, path: path, completionHandlerForFavoriting: completionHandlerForFavoriting)
    }
    
    fileprivate func favorite(id: Int, path: String, completionHandlerForFavoriting: @escaping (_ errorMessage: String?) -> Void) {
        validateAccessToken { (errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForFavoriting(errorMessage!)
                return
            }
            
            guard let url = self.createAniListUrl(withPath: path, andParameters: [:]) else {
                completionHandlerForFavoriting("Couldn't create AniList URL")
                return
            }
            
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = "{\"id\":\"\(id)\"}".data(using: .utf8)
            request.addValue(AniListConstant.HeaderFieldValue.contentTypeJson, forHTTPHeaderField: AniListConstant.HeaderFieldName.contentType)
            request.addValue("Bearer \(UserDefaults.standard.string(forKey: "accessToken")!)", forHTTPHeaderField: AniListConstant.HeaderFieldName.authorization)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                
                if let errorMessage = self.checkDataTaskResponseForError(data: data, response: response, error: error) {
                    completionHandlerForFavoriting(errorMessage)
                    return
                }
                
                let data = data!
                
                guard let jsonObject = self.deserializeJson(fromData: data) else {
                    completionHandlerForFavoriting("Couldn't deserialize data into a JSON object")
                    return
                }
                
                print("RECEIVED THE FOLLOWING JSON OBJECT AFTER FAVORITING: \(jsonObject)")
                completionHandlerForFavoriting(nil)
                
            }
            
            task.resume()
            
        }
    }

    
    // MARK: - Helper methods
    
    /* 
        This method takes the three arguments of data task's completion handler
        as parameters and checks if:
        There was no error
     */
    func checkDataTaskResponseForError(data: Data?, response: URLResponse?, error: Error?) -> String? {
        guard error == nil else {
            return error!.localizedDescription
        }
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
            statusCode >= 200 && statusCode <= 299 else {
                return "Unsuccessful response status code"
        }
        
        guard let _ = data else {
            return "Couldn't retrieve data"
        }
        
        return nil
        
    }
    
    /*
        This method takes in a path (like "browse/{seriesType}") and a dictionary of
        parameters (parameterKey:parameterValue) and creates an AniList URL from it
        by using an URLComponents object where the path will be appended to the base
        URL of the AniList API, a query string will be created from the parameters
        and assigned to the URLComponents' object's queryItems property (if there were parameters)
    */
    func createAniListUrl(withPath path: String, andParameters parameters: [String:Any]) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = AniListConstant.URL.scheme
        urlComponents.host = AniListConstant.URL.host
        urlComponents.path = "\(AniListConstant.URL.basePath)\(path)"
        
        var queryItems = [URLQueryItem]()
        for (parameterName, parameterValue) in parameters {
            let queryItem = URLQueryItem(name: parameterName, value: "\(parameterValue)")
            queryItems.append(queryItem)
        }
        
        if queryItems.count > 0 {
            urlComponents.queryItems = queryItems
        }
        
        return urlComponents.url
        
    }
    
    /*  
        This function takes in a path string and replacing pairs as parameters.
        The pairs dictionary should contain placeholder strings as a key and
        the string they should be replaced by as a correspondent value
     */
    fileprivate func replacePlaceholders(inPath path: String, withReplacingPairs pairs: [String:String]) -> String {
        var newPath = path
        for (placeholder, replacement) in pairs {
            newPath = newPath.replacingOccurrences(of: "{\(placeholder)}", with: replacement)
        }
        return newPath
    }
    
    fileprivate func deserializeJson(fromData data: Data) -> Any? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return jsonObject
        } catch {
            print("Error when trying to deserialize JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    fileprivate func isAccessTokenValid() -> Bool {
        let expirationTimestamp = UserDefaults.standard.integer(forKey: "expirationTimestamp")
        let timestampNow = Int(Date().timeIntervalSince1970)
        let isAccessTokenValid = expirationTimestamp > timestampNow
        return isAccessTokenValid
    }
    
    fileprivate func validateAccessToken(completionHandlerForValidation: @escaping (_ errorMessage: String?) -> Void) {
        if isAccessTokenValid() {
            completionHandlerForValidation(nil)
            return
        }
        
        getAccessToken(withRefreshToken: true) { (accessToken, _, errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForValidation(errorMessage!)
                return
            }
            
            guard let accessToken = accessToken else {
                completionHandlerForValidation("Couldn't get access token")
                return
            }
            
            UserDefaults.standard.set(accessToken.accessTokenValue, forKey: "accessToken")
            UserDefaults.standard.set(accessToken.expirationTimestamp, forKey: "expirationTimestamp")
            
            completionHandlerForValidation(nil)
            
        }
    }
    
}
