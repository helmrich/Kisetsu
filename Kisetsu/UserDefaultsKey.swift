//
//  UserDefaultsKey.swift
//  AniManager
//
//  Created by Tobias Helmrich on 05.06.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import Foundation

enum UserDefaultsKey: String {
    // Start
    case isNotFirstStart
    // Authentication
    case accessToken, refreshToken, expirationTimestamp, grantType, tokenType
    // Content and Style
    case titleLanguage, theme, showExplicitContent, showTagsWithSpoilers, showBioWithSpoilers, downloadHighQualityImages, favoriteGenres, selectedBrowseFiltersData, browseSeriesType
}
