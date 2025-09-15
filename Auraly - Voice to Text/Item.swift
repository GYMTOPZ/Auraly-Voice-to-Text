//
//  Item.swift
//  Auraly - Voice to Text
//
//  Created by PEDRO MEZA on 9/15/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
