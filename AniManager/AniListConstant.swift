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
    }
}
