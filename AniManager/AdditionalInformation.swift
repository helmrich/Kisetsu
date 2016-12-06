//
//  AdditionalInformation.swift
//  AniManager
//
//  Created by Tobias Helmrich on 04.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

struct AdditionalInformation {
    // General
    let characters: [Character]?
    let staff: [Staff]?
    let relations: [Any]?
    
    // Anime-specific
    let studios: [Studio]?
    let externalLinksStrings: [String]?
}
