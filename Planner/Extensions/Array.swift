//
//  Array.swift
//  Planner
//
//  Created by Danny on 12/7/22.
//

import Foundation

extension Array where Element: Hashable {
    func uniqueElements() -> Array {
        var temp = Array()
        var s = Set<Element>()
        for i in self {
            if !s.contains(i) {
                temp.append(i)
                s.insert(i)
            }
        }
        return temp
    }
}
