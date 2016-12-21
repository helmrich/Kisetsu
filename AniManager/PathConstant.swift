//
//  PathConstant.swift
//  AniManager
//
//  Created by Tobias Helmrich on 21.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

extension PathConstant {
    struct Path {
        struct Authentication {
            static let authorize = "auth/authorize"
            static let accessToken = "auth/access_token"
        }
        
        struct UserGet {
            static let authenticatedUserModel = "user"
            static let basicUserModel = "user/{id}"
            static let basicUserModelFromDisplayName = "user/{displayname}"
            static let userFavourites = "user/{id}/favourites"
            static let userFavouritesFromDisplayName = "user/{displayname}/favourites"
            static let userWatchingAndAiringAnimeList = "user/airing"
            static let notifications = "user/notifications"
        }
        
        struct SeriesGet {
            static let basicSeriesModel = "{seriesType}/{id}"
            static let pageSeriesModel = "{seriesType}/{id}/page"
            static let characters = "{seriesType}/{id}/characters"
            static let staff = "{seriesType}/{id}/staff"
            static let actors = "{seriesType}/{id}/actors"
            static let airingAnime = "anime/{id}/airing"
            static let browse = "browse/{seriesType}"
            static let search = "{seriesType}/search/{query}"
        }
        
        struct SeriesPost {
            static let favourite = "{seriesType}/favourite"
        }
        
        struct CharacterGet {
            static let basicCharacterModel = "character/{id}"
            static let pageCharacterModel = "character/{id}/page"
        }
        
        struct CharacterPost {
            static let favourite = "character/favourite"
        }
        
        struct UserList {
            struct AnimeListGet {
                static let animeListModel = "user/{id}/animelist"
                static let animeListModelFromDisplayName = "user/{displayname}/animelist"
                static let rawAnimeListModel = "user/{id}/animelist/raw"
                static let rawAnimeListModelFromDisplayName = "user/{displayname}/animelist/raw"
            }
            
            struct AnimeListPost {
                static let postEntry = "animelist"
            }
            
            struct AnimeListPut {
                static let putEntry = "animelist"
            }
            
            struct AnimeListDelete {
                static let deleteEntry = "animelist/{id}"
            }
            
            struct MangaListGet {
                static let mangaListModel = "user/{id}/mangalist"
                static let mangaListModelFromDisplayName = "user/{displayname}/mangalist"
                static let rawMangaListModel = "user/{id}/mangalist/raw"
                static let rawMangaListModelFromDisplayName = "user/{displayname}/mangalist/raw"
            }
            
            struct MangaListPost {
                static let postEntry = "mangalist"
            }
            
            struct MangaListPut {
                static let putEntry = "mangalist"
            }
            
            struct MangaListDelete {
                static let deleteEntry = "mangalist/{id}"
            }
        }
        
        struct Placeholder {
            static let seriesType = "seriesType"
            static let id = "id"
            static let query = "query"
            static let displayName = "displayname"
        }
    }
}
