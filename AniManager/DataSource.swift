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
    var searchResultsSeriesList: [Series]? = nil
    var selectedSeries: Series? = nil
    
    var selectedAnimeList: [AnimeSeries]? = nil
    var selectedMangaList: [MangaSeries]? = nil
    
    
    func set(parameterValue: String, forBrowseParameterWithName parameterName: String) {
        browseParameters["\(parameterName)"] = parameterValue
    }
    
}
