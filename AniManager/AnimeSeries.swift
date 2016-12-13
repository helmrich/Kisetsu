//
//  AnimeSeries.swift
//  AniManager
//
//  Created by Tobias Helmrich on 24.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

class AnimeSeries: Series {
    let numberOfTotalEpisodes: Int
    let durationPerEpisode: Int?
    let airingStatus: AnimeAiringStatus?
    let youtubeVideoId: String?
    let source: AnimeSource?
    let studios: [Studio]?
    let externalLinks: [ExternalLink]?
    
    // List-specific properties
    var watchedEpisodes: Int?
    
    typealias AnimeSeriesKey = AniListConstant.ResponseKey.AnimeSeries
    
    /*
        Override the superclass' initializer, initialize an
        instance from a dictionary, try to get all values that are
        specific to anime from the dictionary and set the anime's
        properties to them. After that call the superclass' initializer
     */
    override init?(fromDictionary dictionary: [String:Any]) {
        guard let numberOfTotalEpisodes = dictionary[AnimeSeriesKey.numberOfTotalEpisodes] as? Int else {
            return nil
        }
        
        self.numberOfTotalEpisodes = numberOfTotalEpisodes
        
        if let durationPerEpisode = dictionary[AnimeSeriesKey.durationPerEpisode] as? Int {
            self.durationPerEpisode = durationPerEpisode
        } else {
            self.durationPerEpisode = nil
        }
        
        if let airingStatusString = dictionary[AnimeSeriesKey.airingStatus] as? String,
            let airingStatus = AnimeAiringStatus(rawValue: airingStatusString) {
                self.airingStatus = airingStatus
        } else {
            self.airingStatus = nil
        }
        
        if let youtubeVideoId = dictionary[AnimeSeriesKey.youtubeVideoId] as? String {
            self.youtubeVideoId = youtubeVideoId
        } else {
            self.youtubeVideoId = nil
        }
        
        if let sourceString = dictionary[AnimeSeriesKey.source] as? String,
            let source = AnimeSource(rawValue: sourceString) {
                self.source = source
        } else {
            self.source = nil
        }
        
        
        
        if let externalLinkDictionaries = dictionary[AnimeSeriesKey.externalLinksStrings] as? [[String:Any]] {
            var externalLinks = [ExternalLink]()
            for externalLinkDictionary in externalLinkDictionaries {
                if let externalLink = ExternalLink(fromDictionary: externalLinkDictionary) {
                    externalLinks.append(externalLink)
                }
            }
            self.externalLinks = externalLinks
        } else {
            self.externalLinks = nil
        }
        
        if let studioDictionaries = dictionary[AnimeSeriesKey.studios] as? [[String:Any]] {
            var studios = [Studio]()
            for studioDictionary in studioDictionaries {
                if let studioName = studioDictionary[AniListConstant.ResponseKey.Studio.name] as? String {
                    let studio = Studio(name: studioName)
                    studios.append(studio)
                }
            }
            self.studios = studios
        } else {
            self.studios = nil
        }
        
        if let watchedEpisodes = dictionary[AniListConstant.ResponseKey.List.AnimeList.watchedEpisodes] as? Int {
            self.watchedEpisodes = watchedEpisodes
        } else {
            self.watchedEpisodes = nil
        }
        
        super.init(fromDictionary: dictionary)
        
    }
}
