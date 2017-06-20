//
//  User.swift
//  AniManager
//
//  Created by Tobias Helmrich on 11.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

struct User {
    let id: Int
    let displayName: String
    let imageMediumURLString: String
    let imageLargeURLString: String
    let animeTime: Int?
    let readMangaChapters: Int?
    let about: String?
    let adultContent: Bool?
    let imageBannerURLString: String?
    let advancedRating: Bool?
    let advancedRatingNames: [String:[String]]?
    let scoreType: Int?
    
    init?(fromDictionary dictionary: [String:Any]) {
        
        typealias UserResponseKey = AniListConstant.ResponseKey.User
        
        guard let id = dictionary[UserResponseKey.id] as? Int,
        let displayName = dictionary[UserResponseKey.about] as? String,
        let imageMediumURLString = dictionary[UserResponseKey.imageMediumURL] as? String,
            let imageLargeURLString = dictionary[UserResponseKey.imageLargeURL] as? String else {
                return nil
        }
        
        self.id = id
        self.displayName = displayName
        self.imageMediumURLString = imageMediumURLString
        self.imageLargeURLString = imageLargeURLString
        
        if let animeTime = dictionary[UserResponseKey.animeTime] as? Int {
            self.animeTime = animeTime
        } else {
            self.animeTime = nil
        }
        
        if let readMangaChapters = dictionary[UserResponseKey.readMangaChapters] as? Int {
            self.readMangaChapters = readMangaChapters
        } else {
            self.readMangaChapters = nil
        }
        
        if let about = dictionary[UserResponseKey.about] as? String {
            self.about = about
        } else {
            self.about = nil
        }
        
        if let adultContent = dictionary[UserResponseKey.adultContent] as? Bool {
            self.adultContent = adultContent
        } else {
            self.adultContent = nil
        }
        
        if let imageBannerURLString = dictionary[UserResponseKey.imageBannerURL] as? String {
            self.imageBannerURLString = imageBannerURLString
        } else {
            self.imageBannerURLString = nil
        }
        
        if let advancedRating = dictionary[UserResponseKey.advancedRating] as? Bool {
            self.advancedRating = advancedRating
        } else {
            self.advancedRating = nil
        }
        
        if let advancedRatingNames = dictionary[UserResponseKey.advancedRatingNames] as? [String:[String]] {
            self.advancedRatingNames = advancedRatingNames
        } else {
            self.advancedRatingNames = nil
        }
        
        if let scoreType = dictionary[UserResponseKey.animeTime] as? Int {
            self.scoreType = scoreType
        } else {
            self.scoreType = nil
        }
        
    }
}
