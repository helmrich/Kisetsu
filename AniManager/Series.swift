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
    let favorite: Bool?
    let imageBannerUrlString: String?
    let tags: [Tag]?
    
    // Additional informations
    let characters: [Character]?
    let relations: [Series]?
    let relationsAnime: [AnimeSeries]?
    let relationsManga: [MangaSeries]?
    
    /*
        This property stores the combined values of the relationsAnime
        and relationsManga arrays
     */
    
    var allRelations: [Series]? {
        get {
            var combinedRelations = [Series]()
            if let relationsAnime = relationsAnime {
                for relation in relationsAnime {
                    combinedRelations.append(relation)
                }
            }
            if let relationsManga = relationsManga {
                for relation in relationsManga {
                    combinedRelations.append(relation)
                }
            }
            if let relations = relations {
                for relation in relations {
                    combinedRelations.append(relation)
                }
            }
            return combinedRelations
        }
    }
    
    // List-specific properties
    var finishedOn: String?
    var itemListStatus: String?
    var userScore: Int?
    
    typealias SeriesKey = AniListConstant.ResponseKey.Series
    
    /*
         This initializer initializes an instance from a given
         dictionary. Firstly, all values that are also included
         in a series' small model are extracted from the dictionary
         and casted to the appropriate type. If all values can be
         extracted, the instance's properties are set, if not,
         the initializer fails and returns nil.
        
         After that, the dictionary should be searched for keys that
         are only available in the extended/list model and if they exist,
         the appropriate properties should also be set. If not, the
         properties should be set to nil.
    */
    init?(fromDictionary dictionary: [String:Any]) {
        
        // Extract and set all values that are included in the small model
        guard let id = dictionary[SeriesKey.id] as? Int,
                let seriesTypeString = dictionary[SeriesKey.seriesType] as? String,
                let seriesType = SeriesType(rawValue: seriesTypeString),
                let titleRomaji = dictionary[SeriesKey.titleRomaji] as? String,
                let titleEnglish = dictionary[SeriesKey.titleEnglish] as? String,
                let titleJapanese = dictionary[SeriesKey.titleJapanese] as? String,
                let mediaTypeString = dictionary[SeriesKey.mediaType] as? String,
                let type = MediaType(rawValue: mediaTypeString),
                let synonyms = dictionary[SeriesKey.synonyms] as? [String],
                let genres = dictionary[SeriesKey.genres] as? [String],
                let isAdult = dictionary[SeriesKey.adult] as? Bool,
                let averageScore = dictionary[SeriesKey.averageScore] as? Double,
                let popularity = dictionary[SeriesKey.popularity] as? Int,
                let imageMediumUrlString = dictionary[SeriesKey.imageMediumUrl] as? String,
                let imageLargeUrlString = dictionary[SeriesKey.imageLargeUrl] as? String else {
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
        
        /* 
            Extract and set all values (if there are ones) that are
            included in the extended model
         */
        
        if let seasonId = dictionary[SeriesKey.season] as? Int {
            self.seasonId = seasonId
        } else {
            self.seasonId = nil
        }
        
        if let description = dictionary[SeriesKey.description] as? String {
            self.description = description
        } else {
            self.description = nil
        }
        
        if let favorite = dictionary[SeriesKey.favourite] as? Bool {
            self.favorite = favorite
        } else {
            self.favorite = nil
        }
        
        if let imageBannerUrlString = dictionary[SeriesKey.imageBannerUrl] as? String {
            self.imageBannerUrlString = imageBannerUrlString
        } else {
            self.imageBannerUrlString = nil
        }
        
        if let tagDictionaries = dictionary[SeriesKey.tags] as? [[String:Any]],
            let tags = Tag.createTagArray(fromDictionaries: tagDictionaries) {
            self.tags = tags
        } else {
            self.tags = nil
        }
        
        if let characterDictionaries = dictionary[SeriesKey.characters] as? [[String:Any]] {
            var characters = [Character]()
            for characterDictionary in characterDictionaries {
                if let character = Character(fromDictionary: characterDictionary) {
                    characters.append(character)
                }
            }
            self.characters = characters
        } else {
            self.characters = nil
        }
        
        if let relationDictionaries = dictionary[SeriesKey.relations] as? [[String:Any]] {
            var relations = [Series]()
            for relationDictionary in relationDictionaries {
                if let animeSeries = AnimeSeries(fromDictionary: relationDictionary) {
                    relations.append(animeSeries)
                } else if let mangaSeries = MangaSeries(fromDictionary: relationDictionary) {
                    relations.append(mangaSeries)
                }
            }
            self.relations = relations
        } else {
            self.relations = nil
        }
        
        if let relationAnimeDictionaries = dictionary[SeriesKey.relationsAnime] as? [[String:Any]] {
            var relationsAnime = [AnimeSeries]()
            for relationAnimeDictionary in relationAnimeDictionaries {
                if let animeSeries = AnimeSeries(fromDictionary: relationAnimeDictionary) {
                    relationsAnime.append(animeSeries)
                }
            }
            self.relationsAnime = relationsAnime
        } else {
            self.relationsAnime = nil
        }
        
        if let relationMangaDictionaries = dictionary[SeriesKey.relationsManga] as? [[String:Any]] {
            var relationsManga = [MangaSeries]()
            for relationMangaDictionary in relationMangaDictionaries {
                if let mangaSeries = MangaSeries(fromDictionary: relationMangaDictionary) {
                    relationsManga.append(mangaSeries)
                }
            }
            self.relationsManga = relationsManga
        } else {
            self.relationsManga = nil
        }
        
        if let finishedOn = dictionary[AniListConstant.ResponseKey.List.finishedOn] as? String {
            self.finishedOn = finishedOn
        } else {
            self.finishedOn = nil
        }
        
        if let itemListStatus = dictionary[AniListConstant.ResponseKey.List.itemListStatus] as? String {
            self.itemListStatus = itemListStatus
        } else {
            self.itemListStatus = nil
        }
        
        if let userScore = dictionary[AniListConstant.ResponseKey.List.userScore] as? Int {
            self.userScore = userScore
        } else {
            self.userScore = nil
        }
    }
}
