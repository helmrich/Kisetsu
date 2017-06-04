//
//  Actor.swift
//  AniManager
//
//  Created by Tobias Helmrich on 04.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

struct Actor {
    let id: Int
    let firstName: String?
    let lastName: String?
    let imageMediumURLString: String?
    let imageLargeURLString: String?
    let language: String?
    
//    let characters: [Character]?
    
    typealias actorKey = AniListConstant.ResponseKey.Actor
    
    init?(fromDictionary dictionary: [String:Any]) {
        guard let id = dictionary[actorKey.id] as? Int else {
            return nil
        }
        self.id = id
        
        if let firstName = dictionary[actorKey.firstName] as? String {
            self.firstName = firstName
        } else {
            self.firstName = nil
        }
        
        if let lastName = dictionary[actorKey.lastName] as? String {
            self.lastName = lastName
        } else {
            self.lastName = nil
        }
        
        if let language = dictionary[actorKey.language] as? String {
            self.language = language
        } else {
            self.language = nil
        }
        
        if let imageMediumURLString = dictionary[actorKey.imageMediumURL] as? String {
            self.imageMediumURLString = imageMediumURLString
        } else {
            self.imageMediumURLString = nil
        }
        
        if let imageLargeURLString = dictionary[actorKey.imageLargeURL] as? String {
            self.imageLargeURLString = imageLargeURLString
        } else {
            self.imageLargeURLString = nil
        }
    }
}
