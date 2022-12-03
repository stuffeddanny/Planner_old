//
//  Tag.swift
//  Planner
//
//  Created by Danny on 12/3/22.
//

import SwiftUI

struct Tag: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var text: String
    var color: Color
}
