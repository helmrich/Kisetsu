//
//  Season.swift
//  AniManager
//
//  Created by Tobias Helmrich on 24.11.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

enum Season: String {
    case winter, spring, summer, fall
    
    static let allSeasonStrings = [
        winter.rawValue,
        spring.rawValue,
        summer.rawValue,
        fall.rawValue
    ]
    
    init?(withSeasonNumber number: Int) {
        switch number {
        case 1:
            self = .winter
        case 2:
            self = .spring
        case 3:
            self = .summer
        case 4:
            self = .fall
        default:
            return nil
        }
    }
    
    static var current: Season {
        switch DateManager.currentMonth {
        case .january, .february, .march:
            return .winter
        case .april, .may, .june:
            return .spring
        case .july, .august, .september:
            return .summer
        case .october, .november, .december:
            return .fall
        }
    }
    
    static var next: Season {
        switch DateManager.currentMonth {
        case .january, .february, .march:
            return .spring
        case .april, .may, .june:
            return .summer
        case .july, .august, .september:
            return .fall
        case .october, .november, .december:
            return .winter
        }
    }
}
