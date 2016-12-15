//
//  SeriesDetailViewControllerHelper.swift
//  AniManager
//
//  Created by Tobias Helmrich on 14.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import UIKit

extension SeriesDetailViewController {
    func createSeasonString(fromSeasonId seasonId: Int?) -> String? {
        guard let seasonId = seasonId else {
            return nil
        }
        
        /*
         The season ID is a 3-digit number where the first two
         numbers are the last two numbers of the season's year
         and the last number is the season (3 = summer, 4 = fall,
         1 = winter, 2 = spring)
         */
        let seasonIdString = "\(seasonId)"
        let yearPart = seasonIdString.substring(to: seasonIdString.index(before: seasonIdString.endIndex))
        let seasonNumber = seasonId % 10
        
        /*
         Because the API just returns two digits for the year and
         the database currently has series since 1951 it has to be
         assumed for now that if the season ID is larger than 504
         the series was released in the 20th century whereas if it's
         smaller the series was released in the 21th century
         */
        let year = seasonId > 504 ? "19\(yearPart)" : "20\(yearPart)"
        guard let season = Season(withSeasonNumber: seasonNumber) else {
            return nil
        }
        
        return "\(season.rawValue.capitalized) \(year)"
    }
    
    func getReleaseYear(fromSeasonId seasonId: Int?) -> Int? {
        
        guard let seasonId = seasonId else {
            return nil
        }
        
        /*
         The season ID is a 3-digit number where the first two
         numbers are the last two numbers of the season's year
         and the last number is the season (3 = summer, 4 = fall,
         1 = winter, 2 = spring)
         */
        let seasonIdString = "\(seasonId)"
        let yearPart = seasonIdString.substring(to: seasonIdString.index(before: seasonIdString.endIndex))
        if yearPart == "" {
            return nil
        }
        
        /*
         Because the API just returns two digits for the year and
         the database currently has series since 1951 it has to be
         assumed for now that if the season ID is larger than 504
         the series was released in the 20th century whereas if it's
         smaller the series was released in the 21th century
         */
        let yearString = seasonId > 504 ? "19\(yearPart)" : "20\(yearPart)"
        
        return Int(yearString)
    }
}
