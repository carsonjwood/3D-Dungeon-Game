//
//  Item.swift
//  3D Dungeon Game
//
//  Created by Carson Wood on 4/28/25.
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
