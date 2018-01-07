//
//  Item.swift
//  Todoey
//
//  Created by Jake Sanders on 1/6/18.
//  Copyright © 2018 Jake Sanders. All rights reserved.
//

import Foundation

class Item: Codable {
    var title: String = ""
    var done: Bool = false
    
    init() {}
    init( _ title: String) { self.title = title }
}
