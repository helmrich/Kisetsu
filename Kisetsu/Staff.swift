//
//  Staff.swift
//  AniManager
//
//  Created by Tobias Helmrich on 04.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

struct Staff: Person {
    // Small Model
    let id: Int
    let firstName: String?
    let lastName: String?
    let imageMediumURLString: String?
    let imageLargeURLString: String?
    let language: String?
    
    // Full Model
    let firstNameJapanese: String?
    let lastNameJapanese: String?
    let info: String?
    let isFavorite: Bool?
    
    var fullName: String {
        return getFullName(forFirstName: firstName, andLastName: lastName, inJapaneseOrder: false)
    }
    
    var fullNameJapanese: String {
        return getFullName(forFirstName: firstNameJapanese, andLastName: lastNameJapanese, inJapaneseOrder: true)
    }
    
    typealias staffKey = AniListConstant.ResponseKey.Staff
    
    init?(fromDictionary dictionary: [String:Any]) {
        guard let id = dictionary[staffKey.id] as? Int else {
            return nil
        }
        self.id = id
        
        if let firstName = dictionary[staffKey.firstName] as? String {
            self.firstName = firstName
        } else {
            self.firstName = nil
        }
        
        if let lastName = dictionary[staffKey.lastName] as? String {
            self.lastName = lastName
        } else {
            self.lastName = nil
        }
        
        if let language = dictionary[staffKey.language] as? String {
            self.language = language
        } else {
            self.language = nil
        }
        
        if let imageMediumURLString = dictionary[staffKey.imageMediumURL] as? String {
            self.imageMediumURLString = imageMediumURLString
        } else {
            self.imageMediumURLString = nil
        }
        
        if let imageLargeURLString = dictionary[staffKey.imageLargeURL] as? String {
            self.imageLargeURLString = imageLargeURLString
        } else {
            self.imageLargeURLString = nil
        }
        
        if let firstNameJapanese = dictionary[staffKey.firstNameJapanese] as? String {
            self.firstNameJapanese = firstNameJapanese
        } else {
            self.firstNameJapanese = nil
        }
        
        if let lastNameJapanese = dictionary[staffKey.lastNameJapanese] as? String {
            self.lastNameJapanese = lastNameJapanese
        } else {
            self.lastNameJapanese = nil
        }
        
        if let info = dictionary[staffKey.info] as? String {
            self.info = info
        } else {
            self.info = nil
        }
        
        if let isFavorite = dictionary[staffKey.favourite] as? Bool {
            self.isFavorite = isFavorite
        } else {
            self.isFavorite = nil
        }
    }
    
    func getFullName(forFirstName firstName: String?, andLastName lastName: String?, inJapaneseOrder: Bool) -> String {
        /*
         Switch over the character's first and last name
         and set the character name label's text depending
         on which values are available
         */
        switch (firstName, lastName) {
        case (.some, .none):
            return firstName!
        case (.none, .some):
            return lastName!
        case (.none, .none):
            return ""
        case (.some, .some):
            if inJapaneseOrder {
                return "\(lastName!) \(firstName!)"
            } else {
                return "\(firstName!) \(lastName!)"
            }
        }
    }
}
