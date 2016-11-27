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
    
    typealias seriesKey = AniListConstant.ResponseKey.Series
    typealias animeSeriesKey = AniListConstant.ResponseKey.AnimeSeries
    
    /*
        Override the superclass' initializer, initialize an
        instance from a dictionary, try to get all values that are
        specific to anime from the dictionary and set the anime's
        properties to them. After that call the superclass' initializer
     */
    override init?(fromDictionary dictionary: [String:Any]) {
        guard let numberOfTotalEpisodes = dictionary["total_episodes"] as? Int else {
            return nil
        }
        
        self.numberOfTotalEpisodes = numberOfTotalEpisodes
        
        if let durationPerEpisode = dictionary["duration"] as? Int {
            self.durationPerEpisode = durationPerEpisode
        } else {
            self.durationPerEpisode = nil
        }
        
        if let airingStatusString = dictionary["airing_status"] as? String,
            let airingStatus = AnimeAiringStatus(rawValue: airingStatusString) {
                self.airingStatus = airingStatus
        } else {
            self.airingStatus = nil
        }
        
        if let youtubeVideoId = dictionary["youtube_id"] as? String {
            self.youtubeVideoId = youtubeVideoId
        } else {
            self.youtubeVideoId = nil
        }
        
        if let sourceString = dictionary["source"] as? String,
            let source = AnimeSource(rawValue: sourceString) {
                self.source = source
        } else {
            self.source = nil
        }
        
        super.init(fromDictionary: dictionary)
        
    }
}
