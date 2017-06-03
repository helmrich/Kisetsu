//
//  ListName.swift
//  AniManager
//
//  Created by Tobias Helmrich on 11.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

enum AnimeListName: String {
    case watching = "Watching"
    case planToWatch = "Plan to Watch"
    case completed = "Completed"
    case onHold = "On Hold"
    case dropped = "Dropped"
    
    static let allNameStrings = [
            watching.rawValue,
            planToWatch.rawValue,
            completed.rawValue,
            onHold.rawValue,
            dropped.rawValue
    ]
    
    static let allKeys = [
            watching.asKey(),
            planToWatch.asKey(),
            completed.asKey(),
            onHold.asKey(),
            dropped.asKey()
    ]
    
    static let allValues = [
        watching,
        planToWatch,
        completed,
        onHold,
        dropped
    ]
    
    func asKey() -> String {
        switch self {
        case .watching:
            return "watching"
        case .planToWatch:
            return "plan_to_watch"
        case .completed:
            return "completed"
        case .onHold:
            return "on_hold"
        case .dropped:
            return "dropped"
        }
    }
}

enum MangaListName: String {
    case reading = "Reading"
    case planToRead = "Plan to Read"
    case completed = "Completed"
    case onHold = "On Hold"
    case dropped = "Dropped"
    
    static let allNameStrings = [
            reading.rawValue,
            planToRead.rawValue,
            completed.rawValue,
            onHold.rawValue,
            dropped.rawValue
    ]
    
    static let allKeys = [
            reading.asKey(),
            planToRead.asKey(),
            completed.asKey(),
            onHold.asKey(),
            dropped.asKey()
    ]
    
    static let allValues = [
        reading,
        planToRead,
        completed,
        onHold,
        dropped
    ]
    
    func asKey() -> String {
        switch self {
        case .reading:
            return "reading"
        case .planToRead:
            return "plan_to_read"
        case .completed:
            return "completed"
        case .onHold:
            return "on_hold"
        case .dropped:
            return "dropped"
        }
    }
}
