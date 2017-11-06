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
    
    // MARK: - Singleton
    static let shared = DataSource()
    fileprivate init() {}
    
    // MARK: - Series Detail
    var selectedSeries: Series? = nil
    
    // MARK: - Genres
    var genres = [String]()
    
    // MARK: - Home
    var currentlyAiringSeriesList = [Series]()
    var currentSeasonSeriesList = [Series]()
    var nextSeasonSeriesList = [Series]()
    var continueWatchingSeriesList = [Series]()
    var continueReadingSeriesList = [Series]()
    var recommendationsSeriesList = [Series]()
    var mostPopularAnimeSeriesList = [Series]()
    var topRatedAnimeSeriesList = [Series]()
    
//    var mostPopularGenreSeriesLists = [String:[Series]]()
    
    var mostPopularMangaSeriesList = [Series]()
    var topRatedMangaSeriesList = [Series]()
    
    
    // MARK: - Browse
    var selectedBrowseFilters: [String:[IndexPath:String]?] = [
        "Sort By": [IndexPath:String](),
        "Season": [IndexPath:String](),
        "Status": [IndexPath:String](),
        "Type": [IndexPath:String](),
        "Genres": [IndexPath:String](),
        "Year": [IndexPath:String]()
    ]
    var browseParameters: [String:Any] = [
        AniListConstant.ParameterKey.Browse.sort: AniListConstant.ParameterValue.Browse.Sort.Score.descending
    ]
    var browseSeriesList: [Series]? = nil
    
    var filterSections: [FilterSection] = [
        FilterSection(name: "Sort By", items: ["Score", "Popularity"]),
        FilterSection(name: "Season", items: Season.allSeasonStrings),
        FilterSection(name: "Status", items: AnimeAiringStatus.allStatusStrings),
        FilterSection(name: "Type", items: MediaType.allMediaTypeStrings),
        FilterSection(name: "Genres", items: [String]()),
        FilterSection(name: "Year", items: [Int](1951...DateManager.currentYear + 1).reversed())
    ]
    
    
    // MARK: - Search
    var searchResultsSeriesList: [Series]? = nil
    
    // MARK: - Lists
    var selectedAnimeList: [AnimeSeries]? = nil
    var selectedMangaList: [MangaSeries]? = nil
    
    var animeWatchingList = [Series]()
    var animePlanToWatchList = [Series]()
    var animeCompletedList = [Series]()
    var animeOnHoldList = [Series]()
    var animeDroppedList = [Series]()
    
    var mangaReadingList = [Series]()
    var mangaPlanToReadList = [Series]()
    var mangaCompletedList = [Series]()
    var mangaOnHoldList = [Series]()
    var mangaDroppedList = [Series]()
    
    // MARK: - Settings
    var settings: [[String:[String]]] = [
        ["Content": [
                    "Show Explicit Content",
                    "Show Tags with Spoilers",
                    "Show Spoilers in Bio",
//                    "Rating System",
                    "Favorite Genres",
                    "Preferred Title Language"
        ]],
        ["Appearance": [
                "Dark Theme",
                "High-Quality Images"
        ]],
        ["Advanced": ["Clear Disk Image Cache"]],
        ["Feedback": ["Send Feedback"]],
        ["AniList": ["Forum"]],
        ["Account": [
                    "User Profile",
                    "Logout"
        ]]
    ]
    
    
    // MARK: - Functions
    
    func set(parameterValue: String, forBrowseParameterWithName parameterName: String) {
        browseParameters["\(parameterName)"] = parameterValue
    }
    
    /*
        This function gets all genres from the genres.plist file and sets
        the browseFilters property's value for the "Genres" key to the
        retrieved genres
     */
    func getGenres() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("genres.plist")
        
        if let genresFromFile = NSArray(contentsOf: fileURL) as? [String],
            genresFromFile.count > 0 {
            genres = genresFromFile
            
            for (index, filterSection) in filterSections.enumerated() {
                if filterSection.name == "Genres" {
                    filterSections[index].items = genres
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
    
    func getUserListPreviewImageURL(forSeriesType seriesType: SeriesType, andListNameString listNameString: String) -> URL? {
        
        let seriesListForPreviewImage: [Series]
        
        switch seriesType {
        case .anime:
            guard let listName = AnimeListName(rawValue: listNameString) else {
                return nil
            }
            
            switch listName {
            case .watching:
                seriesListForPreviewImage = animeWatchingList
            case .planToWatch:
                seriesListForPreviewImage = animePlanToWatchList
            case .completed:
                seriesListForPreviewImage = animeCompletedList
            case .onHold:
                seriesListForPreviewImage = animeOnHoldList
            case .dropped:
                seriesListForPreviewImage = animeDroppedList
            }
        case .manga:
            guard let listName = MangaListName(rawValue: listNameString) else {
                return nil
            }
            
            switch listName {
            case .reading:
                seriesListForPreviewImage = mangaReadingList
            case .planToRead:
                seriesListForPreviewImage = mangaPlanToReadList
            case .completed:
                seriesListForPreviewImage = mangaCompletedList
            case .onHold:
                seriesListForPreviewImage = mangaOnHoldList
            case .dropped:
                seriesListForPreviewImage = mangaDroppedList
            }
        }
        
        for series in seriesListForPreviewImage {
            if let imageBannerURLString = series.imageBannerURLString,
                let imageBannerURL = URL(string: imageBannerURLString) {
                return imageBannerURL
            }
        }
        
        return nil
    }
}
