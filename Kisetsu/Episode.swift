//
//  Episode.swift
//  Kisetsu
//
//  Created by Tobias Helmrich on 24.06.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import Foundation

struct Episode {
    let title: String
    let description: String
    let guid: String?
    var mediaId: String?
    var number: Double?
    
    // URLs
    let crunchyrollURL: URL?
    let imageSmallURL: URL?
    let imageMediumURL: URL?
    let imageThumbnailURL: URL?
    let imageLargeURL: URL?
    let imageFullURL: URL?
}
