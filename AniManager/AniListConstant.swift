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
        
        struct Placeholder {
            static let seriesType = "seriesType"
            static let id = "id"
            static let query = "query"
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
    }
}
