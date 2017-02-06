//
//  MediaStatus.swift
//  AniManager
//
//  Created by Tobias Helmrich on 24.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

enum AnimeAiringStatus: String {
    case finishedAiring = "Finished Airing"
    case currentlyAiring = "Currently Airing"
    case notYetAired = "Not Yet Aired"
    case cancelled = "Cancelled"
    
    static let allStatusStrings = [
        finishedAiring.rawValue,
        currentlyAiring.rawValue,
        notYetAired.rawValue,
        cancelled.rawValue
    ]
}

enum MangaPublishingStatus: String {
    case finishedPublishing = "Finished Publishing"
    case publishing = "Publishing"
    case notYetPublished = "Not Yet Published"
    case cancelled = "Cancelled"
    
    static let allStatusStrings = [
        finishedPublishing.rawValue,
        publishing.rawValue,
        notYetPublished.rawValue,
        cancelled.rawValue
    ]
}
