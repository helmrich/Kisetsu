//
//  DataSource.swift
//  AniManager
//
//  Created by Tobias Helmrich on 25.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

struct DataSource {
    
    // MARK: - Properties
    
    static let shared = DataSource()
    
    var browseSeriesInformations: [Series]?
    
    
    // MARK: Initializers
    
    fileprivate init() {}
    
}
