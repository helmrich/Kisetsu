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
                
                typealias seriesKey = AniListConstant.ResponseKey.Series
                
                if seriesType == .anime {
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
    
    func getAuthenticatedUser(completionHandlerForUser: @escaping (_ user: User?, _ errorMessage: String?) -> Void) {
        validateAccessToken { (errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForUser(nil, errorMessage!)
                return
            }
            
            guard let url = self.createAniListUrl(withPath: AniListConstant.Path.UserGet.authenticatedUserModel, andParameters: [:]) else {
                completionHandlerForUser(nil, "Couldn't create AniList URL")
                return
            }
            
            let request = NSMutableURLRequest(url: url)
            request.addValue(AniListConstant.HeaderFieldValue.contentType, forHTTPHeaderField: AniListConstant.HeaderFieldName.contentType)
            request.addValue("Bearer \(UserDefaults.standard.string(forKey: "accessToken")!)", forHTTPHeaderField: AniListConstant.HeaderFieldName.authorization)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                if let errorMessage = self.checkDataTaskResponseForError(data: data, response: response, error: error) {
                    completionHandlerForUser(nil, errorMessage)
                    return
                }
                
                let data = data!
                
                guard let jsonObject = self.deserializeJson(fromData: data) else {
                    completionHandlerForUser(nil, "Couldn't deserialize data into a JSON object")
                    return
                }
                
                guard let userDictionary = jsonObject as? [String:Any],
                    let user = User(fromDictionary: userDictionary) else {
                        completionHandlerForUser(nil, "Couldn't create user object")
                        return
                }
                
                completionHandlerForUser(user, nil)
                
            }
            
            task.resume()
            
        }
    }
    
    func getList(ofType type: SeriesType, withStatus status: String, andUserId userId: Int?, andDisplayName displayName: String?, completionHandlerForList: @escaping (_ seriesList: [Series]?, _ errorMessage: String?) -> Void) {
        
        getStatusListsDictionary(ofType: type, forUserId: userId, forDisplayName: displayName) { (allStatusListsDictionary, errorMessage) in
            
            guard errorMessage == nil else {
                completionHandlerForList(nil, errorMessage!)
                return
            }
            
            guard let allStatusListsDictionary = allStatusListsDictionary else {
                completionHandlerForList(nil, "Couldn't get status lists dictionary")
                return
            }
            
            guard let statusList = allStatusListsDictionary[status] as? [[String:Any]] else {
                completionHandlerForList(nil, "Couldn't get series list from dictionary")
                return
            }
            
            if type == .anime {
                var animeSeriesList = [AnimeSeries]()
                for list in statusList {
                    guard let seriesDictionary = list[type.rawValue] as? [String:Any] else {
                        completionHandlerForList(nil, "Couldn't get series from list")
                        return
                    }
                    
                    guard let animeSeries = AnimeSeries(fromDictionary: seriesDictionary) else {
                        completionHandlerForList(nil, "Couldn't create Anime Series object from dictionary")
                        return
                    }
                    
                    if let watchedEpisodes = list[AniListConstant.ResponseKey.List.AnimeList.watchedEpisodes] as? Int {
                        animeSeries.watchedEpisodes = watchedEpisodes
                    }
                    
                    animeSeriesList.append(animeSeries)
                }
                completionHandlerForList(animeSeriesList, nil)
                return
            } else if type == .manga {
                var mangaSeriesList = [MangaSeries]()
                for list in statusList {
                    guard let seriesDictionary = list[type.rawValue] as? [String:Any] else {
                        completionHandlerForList(nil, "Couldn't get series from list")
                        return
                    }
                    
                    guard let mangaSeries = MangaSeries(fromDictionary: seriesDictionary) else {
                        completionHandlerForList(nil, "Couldn't create Anime Series object from dictionary")
                        return
                    }
                    
                    if let readChapters = list[AniListConstant.ResponseKey.List.MangaList.readChapters] as? Int {
                        mangaSeries.readChapters = readChapters
                    }
                    
                    if let readVolumes = list[AniListConstant.ResponseKey.List.MangaList.readVolumes] as? Int {
                        mangaSeries.readVolumes = readVolumes
                    }
                    
                    mangaSeriesList.append(mangaSeries)
                }
                completionHandlerForList(mangaSeriesList, nil)
                return
            } else {
                completionHandlerForList(nil, "Invalid series type")
                return
            }
        }
    }
    
    func getStatusListsDictionary(ofType type: SeriesType, forUserId userId: Int?, forDisplayName displayName: String?, completionHandlerForLists: @escaping (_ lists: [String:Any]?, _ errorMessage: String?) -> Void) {
        validateAccessToken { (errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForLists(nil, errorMessage!)
                return
            }
            
            let path: String
            if type == .anime {
                if let userId = userId {
                    let placeholderPath = AniListConstant.Path.UserList.AnimeListGet.animeListModel
                    path = self.replacePlaceholders(inPath: placeholderPath, withReplacingPairs: [AniListConstant.Path.Placeholder.id: "\(userId)"])
                } else if let displayName = displayName {
                    let placeholderPath = AniListConstant.Path.UserList.AnimeListGet.animeListModelFromDisplayName
                    path = self.replacePlaceholders(inPath: placeholderPath, withReplacingPairs: [AniListConstant.Path.Placeholder.displayName: displayName])
                } else {
                    completionHandlerForLists(nil, "No username or user ID available")
                    return
                }
            } else if type == .manga {
                if let userId = userId {
                    let placeholderPath = AniListConstant.Path.UserList.MangaListGet.mangaListModel
                    path = self.replacePlaceholders(inPath: placeholderPath, withReplacingPairs: [AniListConstant.Path.Placeholder.id: "\(userId)"])
                } else if let displayName = displayName {
                    let placeholderPath = AniListConstant.Path.UserList.MangaListGet.mangaListModelFromDisplayName
                    path = self.replacePlaceholders(inPath: placeholderPath, withReplacingPairs: [AniListConstant.Path.Placeholder.displayName: displayName])
                } else {
                    completionHandlerForLists(nil, "No username or user ID available")
                    return
                }
            } else {
                completionHandlerForLists(nil, "Invalid series type")
                return
            }
            
            guard let url = self.createAniListUrl(withPath: path, andParameters: [:]) else {
                completionHandlerForLists(nil, "Couldn't create AniList URL")
                return
            }
            
            let request = NSMutableURLRequest(url: url)
            request.addValue(AniListConstant.HeaderFieldValue.contentType, forHTTPHeaderField: AniListConstant.HeaderFieldName.contentType)
            request.addValue("Bearer \(UserDefaults.standard.string(forKey: "accessToken")!)", forHTTPHeaderField: AniListConstant.HeaderFieldName.authorization)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                if let errorMessage = self.checkDataTaskResponseForError(data: data, response: response, error: error) {
                    completionHandlerForLists(nil, errorMessage)
                    return
                }
                
                let data = data!
                
                guard let jsonObject = self.deserializeJson(fromData: data) else {
                    completionHandlerForLists(nil, "Couldn't deserialize data into a JSON object")
                    return
                }
                
                guard let listsDictionary = jsonObject as? [String:Any] else {
                    completionHandlerForLists(nil, "Couldn't create lists dictionary from JSON object")
                    return
                }
                
                guard let allStatusLists = listsDictionary[AniListConstant.ResponseKey.List.allLists] as? [String:Any] else {
                        completionHandlerForLists(nil, "Couldn't get series list from dictionary")
                        return
                }
                
                completionHandlerForLists(allStatusLists, nil)
                
            }
            
            task.resume()
            
        }
    }
    
    func getListInformations(forSeriesOfType type: SeriesType, withId seriesId: Int, forUserId userId: Int?, forDisplayName displayName: String?, completionHandlerForInformations: @escaping (_ status: String?, _ userScore: Int?, _ watchedEpisodes: Int?, _ readChapters: Int?, _ readVolumes: Int?, _ errorMessage: String?) -> Void) {
        getStatusListsDictionary(ofType: type, forUserId: userId, forDisplayName: displayName) { (allStatusListsDictionary, errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForInformations(nil, nil, nil, nil, nil, errorMessage!)
                return
            }
            
            guard let allStatusListsDictionary = allStatusListsDictionary else {
                completionHandlerForInformations(nil, nil, nil, nil, nil, "Couldn't get status lists dictionary")
                return
            }
            
            
            // Create allStatusListSeries variable that contains all
            // series dictionaries that are in ANY status list, then
            // check if there is a series with the specified ID,
            // if there is, extract all values from this series
            var statusKeys: [String]
            if type == .anime {
                statusKeys = AnimeListName.allKeys()
            } else {
                statusKeys = MangaListName.allKeys()
            }
            
            var allStatusListSeriesDictionaries = [[String:Any]]()
            for statusKey in statusKeys {
                if let statusListDictionaries = allStatusListsDictionary[statusKey] as? [[String:Any]] {
                    allStatusListSeriesDictionaries += statusListDictionaries
                }
            }
            
            for seriesDictionary in allStatusListSeriesDictionaries {
                if let id = seriesDictionary["series_id"] as? Int,
                    id == seriesId {
                    typealias StatusListConstant = AniListConstant.ResponseKey.List
                    
                    let status = seriesDictionary[StatusListConstant.itemListStatus] as? String
                    let userScore = seriesDictionary[StatusListConstant.userScore] as? Int
                    let watchedEpisodes = seriesDictionary[StatusListConstant.AnimeList.watchedEpisodes] as? Int
                    let readChapters = seriesDictionary[StatusListConstant.MangaList.readChapters] as? Int
                    let readVolumes = seriesDictionary[StatusListConstant.MangaList.readVolumes] as? Int
                    
                    completionHandlerForInformations(status, userScore, watchedEpisodes, readChapters, readVolumes, nil)
                    return
                    
                }
            }
            
            completionHandlerForInformations(nil, nil, nil, nil, nil, "Series is not in a list")
            
        }
    }
    
    
    // MARK: - POST/PUT
    
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
    
    func submitList(ofType type: SeriesType, withHttpMethod httpMethod: String, seriesId: Int, listStatusString: String, userScore: Int, episodesWatched: Int?, readChapters: Int?, readVolumes: Int?, completionHandlerForSubmission: @escaping (_ errorMessage: String?) -> Void) {
        
        validateAccessToken { (errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForSubmission(errorMessage!)
                return
            }
        
            let path: String
            switch (type, httpMethod) {
            case (.anime, "POST"):
                path = AniListConstant.Path.UserList.AnimeListPost.postEntry
            case (.anime, "PUT"):
                path = AniListConstant.Path.UserList.AnimeListPut.putEntry
            case (.manga, "POST"):
                path = AniListConstant.Path.UserList.MangaListPost.postEntry
            case (.manga, "PUT"):
                path = AniListConstant.Path.UserList.MangaListPut.putEntry
            default:
                completionHandlerForSubmission("Invalid type and/or HTTP method")
                return
            }
            
            
            /*
                Check if the passed in list status string is "on hold" in which
                case a hyphen has to be added between the words in order to work
                as a value for the payload
             */
            let listStatus: String
            if listStatusString == "on hold" {
                listStatus = "on-hold"
            } else {
                listStatus = listStatusString
            }
            
            let httpBodyString: String
            if type == .anime,
                let episodesWatched = episodesWatched {
                httpBodyString = "{\"id\":\"\(seriesId)\",\"list_status\":\"\(listStatus)\",\"score\":\"\(userScore)\",\"episodes_watched\":\"\(episodesWatched)\"}"
            } else if type == .manga,
                let readChapters = readChapters,
                let readVolumes = readVolumes {
                httpBodyString = "{\"id\":\"\(seriesId)\",\"list_status\":\"\(listStatus)\",\"score\":\"\(userScore)\",\"chapters_read\":\"\(readChapters)\",\"volumes_read\":\"\(readVolumes)\"}"
            } else {
                completionHandlerForSubmission("Couldn't create HTTP body string")
                return
            }
            
            guard let url = self.createAniListUrl(withPath: path, andParameters: [:]) else {
                completionHandlerForSubmission("Couldn't create AniList URL")
                return
            }
            
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = httpMethod
            request.httpBody = httpBodyString.data(using: .utf8)
            request.addValue(AniListConstant.HeaderFieldValue.contentTypeJson, forHTTPHeaderField: AniListConstant.HeaderFieldName.contentType)
            request.addValue("Bearer \(UserDefaults.standard.string(forKey: "accessToken")!)", forHTTPHeaderField: AniListConstant.HeaderFieldName.authorization)
            
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                
                if let errorMessage = self.checkDataTaskResponseForError(data: data, response: response, error: error) {
                    completionHandlerForSubmission(errorMessage)
                    return
                }
                
                let data = data!
                
                guard let _ = self.deserializeJson(fromData: data) else {
                    completionHandlerForSubmission("Couldn't deserialize data into a JSON object")
                    return
                }
                
                completionHandlerForSubmission(nil)
                
            }
            
            task.resume()
            
        }
        
    }
    
    // MARK: - DELETE
    
    func deleteListEntry(ofType type: SeriesType, withSeriesId seriesId: Int, completionHandlerForDeletion: @escaping (_ errorMessage: String?) -> Void) {
        
        validateAccessToken { (errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForDeletion(errorMessage!)
                return
            }
        
            let replacingPairs = [
                AniListConstant.Path.Placeholder.id: "\(seriesId)"
            ]
            
            let path: String
            if type == .anime {
                path = self.replacePlaceholders(inPath: AniListConstant.Path.UserList.AnimeListDelete.deleteEntry, withReplacingPairs: replacingPairs)
            } else if type == .manga {
                path = self.replacePlaceholders(inPath: AniListConstant.Path.UserList.MangaListDelete.deleteEntry, withReplacingPairs: replacingPairs)
            } else {
                completionHandlerForDeletion("Invalid series type")
                return
            }
            
            guard let url = self.createAniListUrl(withPath: path, andParameters: [:]) else {
                completionHandlerForDeletion("Couldn't create AniList URL")
                return
            }
            
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "DELETE"
            request.addValue(AniListConstant.HeaderFieldValue.contentType, forHTTPHeaderField: AniListConstant.HeaderFieldName.contentType)
            request.addValue("Bearer \(UserDefaults.standard.string(forKey: "accessToken")!)", forHTTPHeaderField: AniListConstant.HeaderFieldName.authorization)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                if let errorMessage = self.checkDataTaskResponseForError(data: data, response: response, error: error) {
                    completionHandlerForDeletion(errorMessage)
                    return
                }
                
                let data = data!
                
                guard let _ = self.deserializeJson(fromData: data) else {
                    completionHandlerForDeletion("Couldn't deserialize data to JSON object")
                    return
                }
                
                completionHandlerForDeletion(nil)
                
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
