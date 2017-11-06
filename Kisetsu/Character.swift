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
    let actors: [Staff]?
    let isFavorite: Bool?
    
    var fullName: String {
        switch (firstName, lastName) {
        case (.some, .none):
            return firstName!
        case (.none, .some):
            return lastName!
        case (.none, .none):
            return ""
        case (.some, .some):
            return "\(firstName!) \(lastName!)"
        }
    }
    
    var spoilerFreeInfo: String? {
        guard let info = info else { return nil }
        let spoilerMarkdownRegularExpression = try! NSRegularExpression(pattern: "~!.*?!~", options: [])
        let matches = spoilerMarkdownRegularExpression.matches(in: info, options: [], range: NSRange(location: 0, length: info.characters.count))
        var infoWithoutSpoilers = info
        matches.forEach {
            let matchNSRange = $0.range
            if let matchRange = matchNSRange.toRange() {
                let lowerBound = info.index(info.startIndex, offsetBy: matchRange.lowerBound)
                let upperBound = info.index(info.startIndex, offsetBy: matchRange.upperBound)
                let matchingSubstring = info.substring(with: lowerBound..<upperBound)
                infoWithoutSpoilers = infoWithoutSpoilers.replacingOccurrences(of: matchingSubstring, with: "(Spoiler)")
            }
        }
        return infoWithoutSpoilers
    }
    
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
        
        if let actorDictionaries = dictionary[characterKey.actor] as? [[String:Any]] {
            var actors = [Staff]()
            for actorDictionary in actorDictionaries {
                if let actor = Staff(fromDictionary: actorDictionary) {
                    actors.append(actor)
                }
            }
            self.actors = actors
        } else {
            self.actors = nil
        }
    }
}
