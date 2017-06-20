//
//  PayloadConstant.swift
//  AniManager
//
//  Created by Tobias Helmrich on 21.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

extension PayloadConstant {
    struct Payload {
        struct UserList {
            struct AnimeList {
                static let id = "id"
                static let listStatus = "list_status"
                static let score = "score"
                static let scoreRaw = "score_raw"
                static let episodesWatched = "episodes_watched"
                static let rewatched = "rewatched"
                static let notes = "notes"
                static let advancedRatingScores = "advanced_rating_scores"
                static let customLists = "custom_lists"
                static let hiddenDefault = "hidden_default"
            }
            
            struct MangaList {
                static let id = "id"
                static let listStatus = "list_status"
                static let score = "score"
                static let scoreRaw = "score_raw"
                static let volumesRead = "volumes_read"
                static let chaptersRead = "chapters_read"
                static let reread = "reread"
                static let notes = "notes"
                static let advancedRatingScores = "advanced_rating_scores"
                static let customLists = "custom_lists"
                static let hiddenDefault = "hidden_default"
            }
        }
    }
}
