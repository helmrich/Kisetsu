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
    
    // General
    var selectedSeries: Series? = nil
    
    // Browse
    let browseFilters: [[String:[Any]]] = [
        ["Sort By": ["Score", "Popularity"]],
        ["Season": Season.allSeasonStrings],
        ["Status": AnimeAiringStatus.allStatusStrings],
        ["Type": MediaType.allMediaTypeStrings],
        ["Genres": Genre.allGenreStrings],
        ["Year": [Int](1951...2018).reversed()]
    ]
    var selectedBrowseFilters: [String:[IndexPath:String]?] = [
        "Sort By": [IndexPath:String](),
        "Season": [IndexPath:String](),
        "Status": [IndexPath:String](),
        "Type": [IndexPath:String](),
        "Genres": [IndexPath:String](),
        "Year": [IndexPath:String]()
    ]
    var browseParameters: [String:Any] = [
        AniListConstant.ParameterKey.Browse.sort: "score-desc"
    ]
    var browseSeriesList: [Series]? = nil
    
    // Search
    var searchResultsSeriesList: [Series]? = nil
    
    // Lists
    var selectedAnimeList: [AnimeSeries]? = nil
    var selectedMangaList: [MangaSeries]? = nil
    
    
    // MARK: - Functions
    
    func set(parameterValue: String, forBrowseParameterWithName parameterName: String) {
        browseParameters["\(parameterName)"] = parameterValue
    }
    
}
