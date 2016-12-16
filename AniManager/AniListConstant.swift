//
//  AniListConstant.swift
//  AniManager
//
//  Created by Tobias Helmrich on 20.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

typealias ParameterConstant = AniListConstant
typealias HeaderFieldConstant = AniListConstant
typealias PathConstant = AniListConstant
typealias ResponseConstant = AniListConstant
typealias PayloadConstant = AniListConstant

struct AniListConstant {
    
    struct Account {
        static let clientId = "YOURCLIENTID"
        static let clientSecret = "YOURCLIENTSECRET"
    }
    
    struct URL {
        static let scheme = "https"
        static let host = "anilist.co"
        static let basePath = "/api/"
    }
}

// MARK: - Path

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

// MARK: Payload

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


// MARK: Parameter

extension ParameterConstant {
    struct ParameterKey {
        struct Authentication {
            static let grantType = "grant_type"
            static let clientId = "client_id"
            static let clientSecret = "client_secret"
            static let redirectUri = "redirect_uri"
            static let responseType = "response_type"
            static let code = "code"
            static let refreshToken = "refresh_token"
        }
        
        struct Browse {
            static let year = "year"
            static let season = "season"
            static let type = "type"
            static let status = "status"
            static let genres = "genres"
            static let genresExclude = "genres_exclude"
            static let sort = "sort"
            static let airingData = "airing_data"
            static let fullPage = "full_page"
            static let page = "page"
        }
    }
    
    struct ParameterValue {
        struct Authentication {
            static let grantTypeAuthorizationCode = "authorization_code"
            static let grantTypeRefreshToken = "refresh_token"
            static let redirectUri = "AniManager://"
            static let responseTypeCode = "code"
        }
    }
}

// MARK: - Header Field

extension HeaderFieldConstant {
    struct HeaderFieldName {
        static let authorization = "Authorization"
        static let contentType = "Content-Type"
    }
    
    struct HeaderFieldValue {
        static let authorizationAccessToken = "Bearer access_token"
        static let contentType = "application/x-www-form-urlencoded"
        static let contentTypeJson = "application/json"
    }
}

// MARK: - Response

extension ResponseConstant {
    struct ResponseKey {
        struct Authentication {
            static let accessToken = "access_token"
            static let tokenType = "token_type"
            static let expires = "expires"
            static let expiresInSeconds = "expires_in"
            static let refreshToken = "refresh_token"
        }
        
        struct Series {
            static let id = "id"
            static let seriesType = "series_type"
            static let titleRomaji = "title_romaji"
            static let titleEnglish = "title_english"
            static let titleJapanese = "title_japanese"
            static let mediaType = "type"
            static let synonyms = "synonyms"
            static let genres = "genres"
            static let adult = "adult"
            static let averageScore = "average_score"
            static let popularity = "popularity"
            static let imageSmallUrl = "image_url_sml"
            static let imageMediumUrl = "image_url_med"
            static let imageLargeUrl = "image_url_lge"
            static let imageBannerUrl = "image_url_banner"
            static let season = "season"
            static let description = "description"
            static let favourite = "favourite"
            static let characters = "characters"
            static let tags = "tags"
        }
        
        struct AnimeSeries {
            static let numberOfTotalEpisodes = "total_episodes"
            static let durationPerEpisode = "duration"
            static let airingStatus = "airing_status"
            static let youtubeVideoId = "youtube_id"
            static let source = "source"
            static let externalLinksStrings = "external_links"
            static let studios = "studio"
        }
        
        struct MangaSeries {
            static let totalVolumes = "total_volumes"
            static let totalChapters = "total_chapters"
            static let publishingStatus = "publishing_status"
        }
        
        struct Character {
            static let id = "id"
            static let firstName = "name_first"
            static let lastName = "name_last"
            static let japaneseName = "name_japanese"
            static let imageMediumUrl = "image_url_med"
            static let imageLargeUrl = "image_url_lge"
            static let info = "info"
            static let role = "role"
            static let favourite = "favourite"
            static let actor = "actor"
        }
        
        struct ExternalLink {
            static let site = "site"
            static let url = "url"
        }
        
        struct Studio {
            static let name = "studio_name"
        }
        
        struct Actor {
            static let id = "id"
            static let firstName  = "name_first"
            static let lastName = "name_last"
            static let language = "language"
            static let imageMediumUrl = "image_url_med"
            static let imageLargeUrl = "image_url_lge"
        }
        
        struct User {
            static let id = "id"
            static let displayName = "display_name"
            static let imageMediumUrl = "image_url_med"
            static let imageLargeUrl = "image_url_lge"
            static let animeTime = "anime_time"
            static let readMangaChapters = "manga_chap"
            static let about = "about"
            static let adultContent = "adult_content"
            static let imageBannerUrl = "image_url_banner"
            static let advancedRating = "advanced_rating"
            static let advancedRatingNames = "advanced_rating_names"
            static let scoreType = "score_type"
        }
        
        struct List {
            static let allLists = "lists"
            static let finishedOn = "finished_on"
            static let itemListStatus = "list_status"
            static let userScore = "score"
            struct AnimeList {
                static let watchedEpisodes = "episodes_watched"
            }
            struct MangaList {
                static let readChapters = "chapters_read"
                static let readVolumes = "volumes_read"
            }
        }
    }
}
