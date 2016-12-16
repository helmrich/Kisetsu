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
    
    var browseSeriesList: [Series]? = nil
    var selectedSeries: Series? = nil
    
    var selectedAnimeList: [AnimeSeries]? = nil
    var selectedMangaList: [MangaSeries]? = nil
    
}
