//
//  DateManager.swift
//  AniManager
//
//  Created by Tobias Helmrich on 15.05.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import Foundation

class DateManager {
    static let dateFormatter = DateFormatter()
    
    static var currentYear: Int {
        dateFormatter.dateFormat = "yyyy"
        return Int(dateFormatter.string(from: Date()))!
    }
    
    static var currentMonth: String {
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: Date())
    }
}
