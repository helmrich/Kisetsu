//
//  Person.swift
//  Kisetsu
//
//  Created by Tobias Helmrich on 29.06.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import Foundation

protocol Person {
    // Small Model
    var id: Int { get }
    var firstName: String? { get }
    var lastName: String? { get }
    var imageMediumURLString: String? { get }
    var imageLargeURLString: String? { get }
    var language: String? { get }
    
    // Full Model
    var firstNameJapanese: String? { get }
    var lastNameJapanese: String? { get }
    var info: String? { get }
    
    init?(fromDictionary dictionary: [String:Any])
}
