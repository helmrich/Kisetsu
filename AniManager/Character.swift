//
//  Character.swift
//  AniManager
//
//  Created by Tobias Helmrich on 04.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

struct Character {
    let id: Int
    let firstName: String?
    let lastName: String?
    let japaneseName: String?
    let info: String?
    let role: String?
    let imageMediumURLString: String?
    let imageLargeURLString: String?
    let actor: Actor?
    let isFavorite: Bool?
    
    typealias characterKey = AniListConstant.ResponseKey.Character
    
    init?(fromDictionary dictionary: [String:Any]) {
        guard let id = dictionary[characterKey.id] as? Int else {
            return nil
        }
        self.id = id
        
        if let firstName = dictionary[characterKey.firstName] as? String {
            self.firstName = firstName
        } else {
            self.firstName = nil
        }
        
        if let lastName = dictionary[characterKey.lastName] as? String {
            self.lastName = lastName
        } else {
            self.lastName = nil
        }
        
        if let japaneseName = dictionary[characterKey.japaneseName] as? String {
            self.japaneseName = japaneseName
        } else {
            self.japaneseName = nil
        }
        
        if let info = dictionary[characterKey.info] as? String {
            self.info = info
        } else {
            self.info = nil
        }
        
        if let role = dictionary[characterKey.role] as? String {
            self.role = role
        } else {
            self.role = nil
        }
        
        if let imageMediumURLString = dictionary[characterKey.imageMediumURL] as? String {
            self.imageMediumURLString = imageMediumURLString
        } else {
            self.imageMediumURLString = nil
        }
        
        if let imageLargeURLString = dictionary[characterKey.imageLargeURL] as? String {
            self.imageLargeURLString = imageLargeURLString
        } else {
            self.imageLargeURLString = nil
        }
        
        if let favourite = dictionary[characterKey.favourite] as? Bool {
            self.isFavorite = favourite
        } else {
            self.isFavorite = nil
        }
        
        if let actorDictionary = dictionary[characterKey.actor] as? [String:Any],
            let actor = Actor(fromDictionary: actorDictionary) {
            self.actor = actor
        } else {
            self.actor = nil
        }
    }
}
