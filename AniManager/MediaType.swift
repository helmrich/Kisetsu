//
//  MediaType.swift
//  AniManager
//
//  Created by Tobias Helmrich on 23.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

enum MediaType: String {
    case tv = "TV"
    case tvShort = "TV Short"
    case movie = "Movie"
    case special = "Special"
    case ova = "OVA"
    case ona = "ONA"
    case music = "Music"
    case manga = "Manga"
    case novel = "Novel"
    case oneShot = "One Shot"
    case doujin = "Doujin"
    case manhua = "Manhua"
    case manhwa = "Manhwa"

    init?(withId id: Int) {
        switch id {
        case 0:
            self = .tv
        case 1:
            self = .tvShort
        case 2:
            self = .movie
        case 3:
            self = .special
        case 4:
            self = .ova
        case 5:
            self = .ona
        case 6:
            self = .music
        case 7:
            self = .manga
        case 8:
            self = .novel
        case 9:
            self = .oneShot
        case 10:
            self = .doujin
        case 11:
            self = .manhua
        case 12:
            self = .manhwa
        default:
            return nil
        }
    }
    
}