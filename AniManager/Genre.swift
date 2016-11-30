//
//  Genre.swift
//  AniManager
//
//  Created by Tobias Helmrich on 24.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

enum Genre: String {
    case action = "Action"
    case adventure = "Adventure"
    case comedy = "Comedy"
    case drama = "Drama"
    case ecchi = "Ecchi"
    case fantasy = "Fantasy"
    case horror = "Horror"
    case mahouShoujo = "Mahou Shoujo"
    case mecha = "Mecha"
    case music = "Music"
    case mystery = "Mystery"
    case psychological = "Psychological"
    case romance = "Romance"
    case sciFi = "Sci-Fi"
    case sliceOfLife = "Slice of Life"
    case sports = "Sports"
    case supernatural = "Supernatural"
    case thriller = "Thriller"
    
    static let allGenreStrings = [
        action.rawValue,
        adventure.rawValue,
        comedy.rawValue,
        drama.rawValue,
        ecchi.rawValue,
        fantasy.rawValue,
        horror.rawValue,
        mahouShoujo.rawValue,
        mecha.rawValue,
        music.rawValue,
        mystery.rawValue,
        psychological.rawValue,
        romance.rawValue,
        sciFi.rawValue,
        sliceOfLife.rawValue,
        sports.rawValue,
        supernatural.rawValue,
        thriller.rawValue
    ]
    
}
