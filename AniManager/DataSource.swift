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
    
    static let shared = DataSource()
    
    var browseSeriesList: [Series]? = nil
    var selectedSeries: Series? = nil
    
    
    
    // MARK: Initializers
    
    fileprivate init() {}
    
}
