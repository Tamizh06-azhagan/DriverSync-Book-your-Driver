//
//  Item.swift
//  DriverSync
//
//  Created by SAIL on 05/06/25.
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
