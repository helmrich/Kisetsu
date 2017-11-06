//
//  ImagesTableViewCellType.swift
//  AniManager
//
//  Created by Tobias Helmrich on 06.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

enum ImagesTableViewCellType: String {
    // Series Detail
    case relations, characters, actors
    
    // Home
    case currentlyAiring, currentSeason, nextSeason, continueReading, continueWatching, recommendations, topRatedAnime, mostPopularAnime, topRatedManga, mostPopularManga, mostPopularGenreAnime
    
    var title: String {
        switch self {
        case .relations:                return "Relations"
        case .characters:               return "Characters"
        case .actors:                   return "Actors"
        case .currentlyAiring:          return "Currently Airing"
        case .currentSeason:            return "Current Season"
        case .nextSeason:               return "Next Season"
        case .continueReading:          return "Continue Reading"
        case .continueWatching:         return "Continue Watching"
        case .recommendations:          return "Recommendations"
        case .topRatedAnime:            return "Top Rated Anime"
        case .mostPopularAnime:         return "Most Popular Anime"
        case .topRatedManga:            return "Top Rated Manga"
        case .mostPopularManga:         return "Most Popular Manga"
        case .mostPopularGenreAnime:    return "Most Popular Genre Anime"
        }
    }
}
