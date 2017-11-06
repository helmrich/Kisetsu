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
    
    static var nextYear: Int {
        dateFormatter.dateFormat = "yyyy"
        return Int(dateFormatter.string(from: Date()))! + 1
    }
    
    static var currentMonth: Month {
        dateFormatter.dateFormat = "MMMM"
        let dateFormatterMonthString = dateFormatter.string(from: Date())
        print(dateFormatterMonthString)
        print(Month(rawValue: dateFormatterMonthString))
        return Month(rawValue: dateFormatterMonthString)!
    }
    
    enum Month: String {
        case january = "January"
        case february = "February"
        case march = "March"
        case april = "April"
        case may = "May"
        case june = "June"
        case july = "July"
        case august = "August"
        case september = "September"
        case october = "October"
        case november = "November"
        case december = "December"
    }
}

extension DateManager {
    
}
