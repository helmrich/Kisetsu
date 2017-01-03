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
    
    // Genres
    var genres = [String]()
    
    // Browse
    var browseFilters: [[String:[Any]]] = [
        ["Sort By": ["Score", "Popularity"]],
        ["Season": Season.allSeasonStrings],
        ["Status": AnimeAiringStatus.allStatusStrings],
        ["Type": MediaType.allMediaTypeStrings],
        ["Genres": [String]()],
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
    
    // Settings
    var settings: [[String:[String]]] = [
        ["Content": [
                    "Show Explicit Content",
                    "Rating System",
                    "Favorite Genres"
        ]],
        ["Advanced": ["Clear Disk Image Cache"]],
        ["Feedback": ["Send Feedback"]],
        ["Account": ["Logout"]]
    ]
    
    
    // MARK: - Functions
    
    func set(parameterValue: String, forBrowseParameterWithName parameterName: String) {
        browseParameters["\(parameterName)"] = parameterValue
    }
    
    func getGenres() {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileUrl = documentsUrl.appendingPathComponent("genres.plist")
        
        if let genresFromFile = NSArray(contentsOf: fileUrl) as? [String],
            genresFromFile.count > 0 {
            genres = genresFromFile
            
            for (index, browseFilter) in browseFilters.enumerated() {
                for (filterName, _) in browseFilter {
                    if filterName == "Genres" {
                        browseFilters[index]["Genres"] = genres
                    }
                }
            }
        }
    }
    
    // This method sets the data source's browse parameters
    func setBrowseParameters() {
        typealias BrowseParameterKey = AniListConstant.ParameterKey.Browse
        
        /*
         At first, the current shared data source's browse parameters
         should be set to an empty dictionary so that it's guaranteed
         that only the currently set filters are set browse parameters
         */
        DataSource.shared.browseParameters = [String:Any]()
        
        /*
            Iterate over all filter names and values in the data source's
            selectedBrowseFilters property
         */
        for (filterName, filterValues) in DataSource.shared.selectedBrowseFilters {
            
            guard let filterValues = filterValues else {
                print("No filter values available")
                break
            }
            
            /*
             If the filter name is "Genres" an empty array of strings should
             be created and filled with all dictionary values in the filter
             values.
             
             Afterwards a genre parameter value should be created
             and set in the shared data source. After that the loop can
             continue to its next iteration.
             
             Currently this only has to be done for the "Genres" filter
             as it's the only one that can have multiple selected filters
             */
            if filterName == "Genres" {
                var genres = [String]()
                for (_, filterValue) in filterValues {
                    genres.append(filterValue)
                }
                let genreParameterValue = createGenreParameterString(fromGenres: genres)
                DataSource.shared.set(parameterValue: genreParameterValue, forBrowseParameterWithName: BrowseParameterKey.genres)
                continue
            }
            
            /*
             Iterate over all filter values, then switch over the filter
             names and set the appropriate parameter values in the shared
             data source
             */
            for (_, filterValue) in filterValues {
                switch filterName {
                case "Sort By":
                    DataSource.shared.set(parameterValue: "\(filterValue)-desc", forBrowseParameterWithName: BrowseParameterKey.sort)
                case "Season":
                    DataSource.shared.set(parameterValue: filterValue, forBrowseParameterWithName: BrowseParameterKey.season)
                case "Status":
                    DataSource.shared.set(parameterValue: filterValue, forBrowseParameterWithName: BrowseParameterKey.status)
                case "Type":
                    DataSource.shared.set(parameterValue: filterValue, forBrowseParameterWithName: BrowseParameterKey.type)
                case "Year":
                    DataSource.shared.set(parameterValue: filterValue, forBrowseParameterWithName: BrowseParameterKey.year)
                default:
                    print("Unknown filter name \(filterName)")
                    break
                }
            }
            
            /*
                Archive the shared data source's selected browse filters dictionary into
                raw data and set it in the user defaults
             */
            let selectedBrowseFiltersDictionaryData = NSKeyedArchiver.archivedData(withRootObject: DataSource.shared.selectedBrowseFilters)
            UserDefaults.standard.set(selectedBrowseFiltersDictionaryData, forKey: "selectedBrowseFiltersData")
        }
    }
    
    /*
     This function creates a parameter string by taking in an array of genre
     strings and connecting all genres with a separating comma
     */
    func createGenreParameterString(fromGenres genres: [String]) -> String {
        var genreParameterString = ""
        for genre in genres {
            if genreParameterString == "" {
                genreParameterString = genre
            } else {
                genreParameterString = "\(genreParameterString),\(genre)"
            }
        }
        return genreParameterString
    }
    
}
