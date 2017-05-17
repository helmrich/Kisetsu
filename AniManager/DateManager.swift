//
//  DateManager.swift
//  AniManager
//
//  Created by Tobias Helmrich on 15.05.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import Foundation

class DateManager {
    static var currentYear: Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let currentYear = Int(dateFormatter.string(from: Date()))
        return currentYear!
    }
}
