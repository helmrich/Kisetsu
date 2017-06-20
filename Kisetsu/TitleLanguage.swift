//
//  TitleLanguage.swift
//  AniManager
//
//  Created by Tobias Helmrich on 28.05.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import Foundation

enum TitleLanguage: String {
    case english = "English"
    case romaji = "Romaji"
    case japanese = "Japanese"
    
    static let all = [
        english.rawValue,
        romaji.rawValue,
        japanese.rawValue
    ]
}
