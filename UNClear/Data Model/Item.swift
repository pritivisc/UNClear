//
//  Item.swift
//  UNClear
//
//  Created by Pritivi S Chhabria on 7/30/20.
//  Copyright © 2020 Chiffonier Inc. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var isChecked: Bool = false
    @objc dynamic var dateCreated: Date = Date()
    var parentCategory = LinkingObjects(fromType: List.self, property: "items")
}
