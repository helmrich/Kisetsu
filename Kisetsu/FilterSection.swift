//
//  FilterSection.swift
//  Kisetsu
//
//  Created by Tobias Helmrich on 22.06.17.
//  Copyright © 2017 Tobias Helmrich. All rights reserved.
//

import Foundation

struct FilterSection {
    var name: String!
    var items: [Any]!
    var collapsed: Bool!
    
    init(name: String, items: [Any], collapsed: Bool = true) {
        self.name = name
        self.items = items
        self.collapsed = collapsed
    }
}
