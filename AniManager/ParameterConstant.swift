//
//  ParameterConstant.swift
//  AniManager
//
//  Created by Tobias Helmrich on 21.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

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
            static let grantTypeClientCredentials = "client_credentials"
            static let grantTypeRefreshToken = "refresh_token"
            static let redirectUri = "AniManager://"
            static let responseTypeCode = "code"
        }
        
        struct Browse {
            struct Sort {
                struct Score {
                    static let ascending = "score-asc"
                    static let descending = "score-desc"
                }
                struct Popularity {
                    static let ascending = "popularity-asc"
                    static let descending = "popularity-desc"
                }
                struct Id {
                    static let ascending = "id-asc"
                    static let descending = "id-desc"
                }
                struct StartDate {
                    static let ascending = "start_date-asc"
                    static let descending = "start_date-desc"
                }
                struct EndDate {
                    static let ascending = "end_date-asc"
                    static let descending = "end_date-desc"
                }
            }
        }
    }
}
