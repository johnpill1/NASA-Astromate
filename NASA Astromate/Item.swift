//
//  Item.swift
//  NASA Astromate
//
//  Created by John Pill on 08/11/2026.
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
