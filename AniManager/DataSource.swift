//
//  DataSource.swift
//  AniManager
//
//  Created by Tobias Helmrich on 25.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

class DataSource {
    
    // MARK: - Properties
    
    // Singleton
    static let shared = DataSource()
    fileprivate init() {}
    
    var browseParameters: [String:Any] = [
//        AniListConstant.ParameterKey.Browse.year: "2016",
//        AniListConstant.ParameterKey.Browse.genres: "Comedy",
        AniListConstant.ParameterKey.Browse.sort: "score-desc",
        //        AniListConstant.ParameterKey.Browse.season: Season.fall.rawValue
    ]
    var browseSeriesList: [Series]? = nil
    var selectedSeries: Series? = nil
    
    var selectedAnimeList: [AnimeSeries]? = nil
    var selectedMangaList: [MangaSeries]? = nil
    
}
