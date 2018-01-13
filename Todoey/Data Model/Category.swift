//
//  Category.swift
//  Todoey
//
//  Created by Jake Sanders on 1/8/18.
//  Copyright © 2018 Jake Sanders. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    @objc dynamic var color : String = ""
    
    let items = List<Item>()
}
