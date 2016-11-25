//
//  MediaStatus.swift
//  AniManager
//
//  Created by Tobias Helmrich on 24.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

enum AnimeAiringStatus: String {
    case finishedAiring = "finished airing"
    case currentlyAiring = "currently airing"
    case notYetAired = "not yet aired"
    case cancelled = "cancelled"
}

enum MangaPublishingStatus: String {
    case finishedPublishing = "finished publishing"
    case publishing = "publishing"
    case notYetPublished = "not yet published"
    case cancelled = "cancelled"
}