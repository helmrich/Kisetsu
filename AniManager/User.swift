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
    let imageMediumUrlString: String
    let imageLargeUrlString: String
    let animeTime: Int?
    let readMangaChapters: Int?
    let about: String?
    let adultContent: Bool?
    let imageBannerUrlString: String?
    let advancedRating: Bool?
    let advancedRatingNames: [String:[String]]?
    let scoreType: Int?
    
    init?(fromDictionary dictionary: [String:Any]) {
        
        typealias UserResponseKey = AniListConstant.ResponseKey.User
        
        guard let id = dictionary[UserResponseKey.id] as? Int,
        let displayName = dictionary[UserResponseKey.about] as? String,
        let imageMediumUrlString = dictionary[UserResponseKey.imageMediumUrl] as? String,
            let imageLargeUrlString = dictionary[UserResponseKey.imageLargeUrl] as? String else {
                return nil
        }
        
        self.id = id
        self.displayName = displayName
        self.imageMediumUrlString = imageMediumUrlString
        self.imageLargeUrlString = imageLargeUrlString
        
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
        
        if let imageBannerUrlString = dictionary[UserResponseKey.imageBannerUrl] as? String {
            self.imageBannerUrlString = imageBannerUrlString
        } else {
            self.imageBannerUrlString = nil
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
