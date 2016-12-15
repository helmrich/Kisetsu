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
    
    static func allNames() -> [String] {
        return [
            self.watching.rawValue,
            self.planToWatch.rawValue,
            self.completed.rawValue,
            self.onHold.rawValue,
            self.dropped.rawValue
        ]
    }
    
    static func allKeys() -> [String] {
        return [
            self.watching.asKey(),
            self.planToWatch.asKey(),
            self.completed.asKey(),
            self.onHold.asKey(),
            self.dropped.asKey()
        ]
    }
    
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
    
    static func allNames() -> [String] {
        return [
            self.reading.rawValue,
            self.planToRead.rawValue,
            self.completed.rawValue,
            self.onHold.rawValue,
            self.dropped.rawValue
        ]
    }
    
    static func allKeys() -> [String] {
        return [
            self.reading.asKey(),
            self.planToRead.asKey(),
            self.completed.asKey(),
            self.onHold.asKey(),
            self.dropped.asKey()
        ]
    }
    
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
