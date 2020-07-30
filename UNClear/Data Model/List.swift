//
//  List.swift
//  UNClear
//
//  Created by Pritivi S Chhabria on 7/30/20.
//  Copyright © 2020 Chiffonier Inc. All rights reserved.
//

import Foundation
import RealmSwift

class List: Object {
    @objc dynamic var title: String = ""
    var items = RealmSwift.List<Item>()
}
