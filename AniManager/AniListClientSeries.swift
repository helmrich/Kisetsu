//
//  AniListClientSeries.swift
//  AniManager
//
//  Created by Tobias Helmrich on 15.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

extension AniListClient {
    /*
     This method tries to get an array of series objects from a specific
     page with a defined type (e.g. anime or manga) and parameters (such as
     release year, genres, sorting, etc.)
     */
    func getSeriesList(fromPage page: Int = 1, ofType seriesType: SeriesType, andParameters parameters: [String:Any], completionHandlerForSeriesList: @escaping (_ seriesList: [Series]?, _ errorMessage: String?) -> Void) {
        
        validateAccessToken { (errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForSeriesList(nil, errorMessage!)
                return
            }
            
            // URL creation and request configuration
            
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
            
            // URL creation and request configuration
            
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
            
            // URL creation and request configuration
            
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
            
            // URL creation and request configuration
            
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
                
                guard let _ = self.deserializeJson(fromData: data) else {
                    completionHandlerForFavoriting("Couldn't deserialize data into a JSON object")
                    return
                }
                
                completionHandlerForFavoriting(nil)
                
            }
            
            task.resume()
            
        }
    }
}
