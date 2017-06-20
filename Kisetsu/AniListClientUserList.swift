//
//  AniListClientUserList.swift
//  AniManager
//
//  Created by Tobias Helmrich on 15.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

extension AniListClient {
    
    // MARK: - GET
    
    /*
        This method gets a series list of a certain type with a specified status (e.g. watching,
        reading, completed, etc.) for a specified user
     */
    func getList(ofType type: SeriesType, withStatus status: String, userId: Int?, andDisplayName displayName: String?, completionHandlerForList: @escaping (_ seriesList: [Series]?, _ errorMessage: String?) -> Void) {
        
        getStatusListsDictionary(ofType: type, forUserId: userId, forDisplayName: displayName) { (allStatusListsDictionary, errorMessage) in
            
            // Error Handling
            guard errorMessage == nil else {
                completionHandlerForList(nil, errorMessage!)
                return
            }
            
            guard let allStatusListsDictionary = allStatusListsDictionary else {
                completionHandlerForList(nil, "Couldn't get status lists dictionary")
                return
            }
            
            /*
                Try to get an array of series dictionaries for the specified status
             */
            guard let statusList = allStatusListsDictionary[status] as? [[String:Any]] else {
                completionHandlerForList(nil, "Couldn't get status list from dictionary")
                return
            }
            
            /*
                Create an empty array of anime/manga series, iterate over all series
                in the status list, try casting the series to a dictionary and creating
                an Anime/MangaSeries object from it. Also get values for watched episodes/
                read chapters/read volumes and assign it to the series' belonging property.
                Then append the series list to the array.
             */
            if type == .anime {
                var animeSeriesList = [AnimeSeries]()
                for series in statusList {
                    guard let seriesDictionary = series[type.rawValue] as? [String:Any] else {
                        completionHandlerForList(nil, "Couldn't get series from list")
                        return
                    }
                    
                    guard let animeSeries = AnimeSeries(fromDictionary: seriesDictionary) else {
                        completionHandlerForList(nil, "Couldn't create Anime Series object from dictionary")
                        return
                    }
                    
                    if let watchedEpisodes = series[AniListConstant.ResponseKey.List.AnimeList.watchedEpisodes] as? Int {
                        animeSeries.watchedEpisodes = watchedEpisodes
                    }
                    
                    animeSeriesList.append(animeSeries)
                }
                completionHandlerForList(animeSeriesList, nil)
                return
            } else if type == .manga {
                var mangaSeriesList = [MangaSeries]()
                for series in statusList {
                    guard let seriesDictionary = series[type.rawValue] as? [String:Any] else {
                        completionHandlerForList(nil, "Couldn't get series from list")
                        return
                    }
                    
                    guard let mangaSeries = MangaSeries(fromDictionary: seriesDictionary) else {
                        completionHandlerForList(nil, "Couldn't create Anime Series object from dictionary")
                        return
                    }
                    
                    if let readChapters = series[AniListConstant.ResponseKey.List.MangaList.readChapters] as? Int {
                        mangaSeries.readChapters = readChapters
                    }
                    
                    if let readVolumes = series[AniListConstant.ResponseKey.List.MangaList.readVolumes] as? Int {
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
    
    /*
        This method gets a dictionary with all status lists for a series type for a user
        that's either specified by an ID or a display name.
     */
    fileprivate func getStatusListsDictionary(ofType type: SeriesType, forUserId userId: Int?, forDisplayName displayName: String?, completionHandlerForLists: @escaping (_ lists: [String:Any]?, _ errorMessage: String?) -> Void) {
        validateAccessToken { (errorMessage) in
            
            // Error Handling
            guard errorMessage == nil else {
                completionHandlerForLists(nil, errorMessage!)
                return
            }
            
            // URL creation and request configuration
            
            // Create a path based on the series type
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
            
            // Create a URL with the path and create a request with it
            guard let url = self.createAniListURL(withPath: path, andParameters: [:]) else {
                completionHandlerForLists(nil, "Couldn't create AniList URL")
                return
            }
            
            let request = self.createDefaultRequest(withURL: url)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                
                // Error Handling
                if let errorMessage = self.checkDataTaskResponseForError(data: data, response: response, error: error) {
                    completionHandlerForLists(nil, errorMessage)
                    return
                }
                
                let data = data!
                
                // JSON Deserialization
                guard let jsonObject = self.deserializeJson(fromData: data) else {
                    completionHandlerForLists(nil, "Couldn't deserialize data into a JSON object")
                    return
                }
                
                guard let listsDictionary = jsonObject as? [String:Any] else {
                    completionHandlerForLists(nil, "Couldn't create lists dictionary from JSON object")
                    return
                }
                
                // Try to get the dictionary with all status lists
                guard let allStatusLists = listsDictionary[AniListConstant.ResponseKey.List.allLists] as? [String:Any] else {
                    completionHandlerForLists(nil, "Couldn't get series list from dictionary")
                    return
                }
                
                completionHandlerForLists(allStatusLists, nil)
                
            }
            
            task.resume()
            
        }
    }
    
    /*
        This method requests list informations for a series specified by type and an ID.
        In this case the series informations that can eventually be received are:
        - List status
        - User score
        - Progress-related values (watched episodes, read chapters/volumes)
     */
    func getListInformations(forSeriesOfType type: SeriesType, withId seriesId: Int, forUserId userId: Int?, forDisplayName displayName: String?, completionHandlerForInformations: @escaping (_ status: String?, _ userScore: Int?, _ watchedEpisodes: Int?, _ readChapters: Int?, _ readVolumes: Int?, _ errorMessage: String?) -> Void) {
        getStatusListsDictionary(ofType: type, forUserId: userId, forDisplayName: displayName) { (allStatusListsDictionary, errorMessage) in
            
            // Error Handling
            guard errorMessage == nil else {
                completionHandlerForInformations(nil, nil, nil, nil, nil, errorMessage!)
                return
            }
            
            guard let allStatusListsDictionary = allStatusListsDictionary else {
                completionHandlerForInformations(nil, nil, nil, nil, nil, "Couldn't get status lists dictionary")
                return
            }
            
            /*
                Create allStatusListSeries variable that contains all
                series dictionaries that are in ANY status list, then
                check if there is a series with the specified ID,
                if there is, extract all values from this series
             */
            var statusKeys: [String]
            if type == .anime {
                statusKeys = AnimeListName.allKeys
            } else {
                statusKeys = MangaListName.allKeys
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
    
    func submitList(ofType type: SeriesType, withHttpMethod httpMethod: String, seriesId: Int, listStatusString: String, userScore: Int, episodesWatched: Int?, readChapters: Int?, readVolumes: Int?, completionHandlerForSubmission: @escaping (_ errorMessage: String?) -> Void) {
        
        validateAccessToken { (errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForSubmission(errorMessage!)
                return
            }
            
            // URL creation and request configuration
            
            // Create the path based on the HTTP method and series type
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
            
            /*
                Set the payload key-value pairs based on the series type and try to create
                a HTTP body from it
            */
            let payloadKeyValuePairs: [String:Any]
            if type == .anime,
                let episodesWatched = episodesWatched {
                typealias AnimePayloadConstant = AniListConstant.Payload.UserList.AnimeList
                payloadKeyValuePairs = [
                    AnimePayloadConstant.id: seriesId,
                    AnimePayloadConstant.listStatus: listStatus,
                    AnimePayloadConstant.score: userScore,
                    AnimePayloadConstant.episodesWatched: episodesWatched
                ]
            } else if type == .manga,
                let readChapters = readChapters,
                let readVolumes = readVolumes {
                typealias MangaPayloadConstant = AniListConstant.Payload.UserList.MangaList
                payloadKeyValuePairs = [
                    MangaPayloadConstant.id: seriesId,
                    MangaPayloadConstant.listStatus: listStatus,
                    MangaPayloadConstant.score: userScore,
                    MangaPayloadConstant.chaptersRead: readChapters,
                    MangaPayloadConstant.volumesRead: readVolumes
                ]
            } else {
                completionHandlerForSubmission("Invalid series type")
                return
            }
            
            guard let httpBody = self.createHttpBody(withKeyValuePairs: payloadKeyValuePairs) else {
                completionHandlerForSubmission("Couldn't create HTTP body")
                return
            }
            
            guard let url = self.createAniListURL(withPath: path, andParameters: [:]) else {
                completionHandlerForSubmission("Couldn't create AniList URL")
                return
            }
            
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = httpMethod
            request.httpBody = httpBody
            request.addValue(AniListConstant.HeaderFieldValue.contentTypeJson, forHTTPHeaderField: AniListConstant.HeaderFieldName.contentType)
            request.addValue("Bearer \(UserDefaults.standard.string(forKey: "accessToken")!)", forHTTPHeaderField: AniListConstant.HeaderFieldName.authorization)
            
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                
                // Error Handling
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
    
    // This method deletes an entry (series) from the list it currently is in
    func deleteListEntry(ofType type: SeriesType, withSeriesId seriesId: Int, completionHandlerForDeletion: @escaping (_ errorMessage: String?) -> Void) {
        
        validateAccessToken { (errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForDeletion(errorMessage!)
                return
            }
            
            // URL creation and request configuration
            
            let replacingPairs = [
                AniListConstant.Path.Placeholder.id: "\(seriesId)"
            ]
            
            /*
                Check the series type and assign an appropriate path to the path property
                based on the series type
             */
            let path: String
            if type == .anime {
                path = self.replacePlaceholders(inPath: AniListConstant.Path.UserList.AnimeListDelete.deleteEntry, withReplacingPairs: replacingPairs)
            } else if type == .manga {
                path = self.replacePlaceholders(inPath: AniListConstant.Path.UserList.MangaListDelete.deleteEntry, withReplacingPairs: replacingPairs)
            } else {
                completionHandlerForDeletion("Invalid series type")
                return
            }
            
            guard let url = self.createAniListURL(withPath: path, andParameters: [:]) else {
                completionHandlerForDeletion("Couldn't create AniList URL")
                return
            }
            
            let request = self.createDefaultRequest(withURL: url)
            request.httpMethod = "DELETE"
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                
                // Error Handling
                if let errorMessage = self.checkDataTaskResponseForError(data: data, response: response, error: error) {
                    completionHandlerForDeletion(errorMessage)
                    return
                }
                
                let data = data!
                
                // JSON Deserialization
                guard let _ = self.deserializeJson(fromData: data) else {
                    completionHandlerForDeletion("Couldn't deserialize data to JSON object")
                    return
                }
                
                completionHandlerForDeletion(nil)
                
            }
            
            task.resume()
            
        }
    }
}
