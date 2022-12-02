//
//  UIApplication.swift
//  Planner
//
//  Created by Danny on 12/2/22.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
