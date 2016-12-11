//
//  ListName.swift
//  AniManager
//
//  Created by Tobias Helmrich on 11.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

enum ListName: String {
    case completed = "Completed"
    case onHold = "On Hold"
    case dropped = "Dropped"
}

enum AnimeListName: String {
    case watching = "Watching"
    case planToWatch = "Plan to Watch"
    
    static func allNames() -> [String] {
        return [
            self.watching.rawValue,
            self.planToWatch.rawValue,
            ListName.completed.rawValue,
            ListName.onHold.rawValue,
            ListName.dropped.rawValue
        ]
    }
}

enum MangaListName: String {
    case reading = "Reading"
    case planToRead = "Plan to Read"
    
    static func allNames() -> [String] {
        return [
            self.reading.rawValue,
            self.planToRead.rawValue,
            ListName.completed.rawValue,
            ListName.onHold.rawValue,
            ListName.dropped.rawValue
        ]
    }
}
