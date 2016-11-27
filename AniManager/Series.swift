//
//  Series.swift
//  AniManager
//
//  Created by Tobias Helmrich on 23.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

class Series {
    let id: Int
    let seriesType: SeriesType
    let titleRomaji: String
    let titleEnglish: String
    let titleJapanese: String
    let mediaType: MediaType
    let synonyms: [String]
    let genres: [String]
    let isAdult: Bool
    let averageScore: Double
    let popularity: Int
    let imageMediumUrlString: String
    let imageLargeUrlString: String
    
    // Not in small model
    let seasonId: Int?
    let description: String?
    let favourite: Bool?
    let imageBannerUrlString: String?
    
    // This initializer initializes an instance from a given
    // dictionary. Firstly, all values that are also included
    // in a series' small model are extracted from the dictionary
    // and casted to the appropriate type. If all values can be
    // extracted, the instance's properties are set, if not,
    // the initializer fails and returns nil. 
    
    // After that, the dictionary should be searched for keys that
    // are only available in the extended model and if they exist,
    // the appropriate properties should also be set. If not, the
    // properties should be set to nil.
    init?(fromDictionary dictionary: [String:Any]) {
        
        typealias seriesKey = AniListConstant.ResponseKey.Series
        
        // Extract and set all values that are included in the small model
        guard let id = dictionary[seriesKey.id] as? Int,
                let seriesTypeString = dictionary[seriesKey.seriesType] as? String,
                let seriesType = SeriesType(rawValue: seriesTypeString),
                let titleRomaji = dictionary[seriesKey.titleRomaji] as? String,
                let titleEnglish = dictionary[seriesKey.titleEnglish] as? String,
                let titleJapanese = dictionary[seriesKey.titleJapanese] as? String,
                let mediaTypeString = dictionary[seriesKey.mediaType] as? String,
                let type = MediaType(rawValue: mediaTypeString),
                let synonyms = dictionary[seriesKey.synonyms] as? [String],
                let genres = dictionary[seriesKey.genres] as? [String],
                let isAdult = dictionary[seriesKey.adult] as? Bool,
                let averageScore = dictionary[seriesKey.averageScore] as? Double,
                let popularity = dictionary[seriesKey.popularity] as? Int,
                let imageMediumUrlString = dictionary[seriesKey.imageMediumUrl] as? String,
                let imageLargeUrlString = dictionary[seriesKey.imageLargeUrl] as? String else {
                    print("Couldn't extract values from dictionary needed to create series...")
                    return nil
        }
        
        self.id = id
        self.seriesType = seriesType
        self.titleRomaji = titleRomaji
        self.titleEnglish = titleEnglish
        self.titleJapanese = titleJapanese
        self.mediaType = type
        self.synonyms = synonyms
        self.genres = genres
        self.isAdult = isAdult
        self.averageScore = averageScore
        self.popularity = popularity
        self.imageMediumUrlString = imageMediumUrlString
        self.imageLargeUrlString = imageLargeUrlString
        
        // Extract and set all values (if there are ones) that are
        // included in the extended model
        if let seasonId = dictionary["id"] as? Int {
            self.seasonId = seasonId
        } else {
            self.seasonId = nil
        }
        
        if let description = dictionary["description"] as? String {
            self.description = description
        } else {
            self.description = nil
        }
        
        if let favourite = dictionary["favourite"] as? Bool {
            self.favourite = favourite
        } else {
            self.favourite = nil
        }
        
        if let imageBannerUrlString = dictionary["image_url_banner"] as? String {
            self.imageBannerUrlString = imageBannerUrlString
        } else {
            self.imageBannerUrlString = nil
        }
    }
}
