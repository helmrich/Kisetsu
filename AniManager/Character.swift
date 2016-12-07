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
    let imageMediumUrlString: String?
    let imageLargeUrlString: String?
    let actor: Actor?
    
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
        
        if let imageMediumUrlString = dictionary[characterKey.imageMediumUrl] as? String {
            self.imageMediumUrlString = imageMediumUrlString
        } else {
            self.imageMediumUrlString = nil
        }
        
        if let imageLargeUrlString = dictionary[characterKey.imageLargeUrl] as? String {
            self.imageLargeUrlString = imageLargeUrlString
        } else {
            self.imageLargeUrlString = nil
        }
        
        if let actorDictionary = dictionary[characterKey.actor] as? [String:Any],
            let actor = Actor(fromDictionary: actorDictionary) {
            self.actor = actor
        } else {
            self.actor = nil
        }
    }
}
