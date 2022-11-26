//
//  DayView.swift
//  Planner
//
//  Created by Danny on 11/25/22.
//

import SwiftUI

struct DayView: View {
    
    let isSelected: Bool
    let dayModel: DayModel
    
    init(for day: DayModel, isSelected: Bool) {
        dayModel = day
        self.isSelected = isSelected
    }
    
    var body: some View {
        ZStack {
            
            if isSelected {
                Circle()
                    .foregroundColor(.red)
            }
            
            
            Text("\(dayModel.id.day)")
                .foregroundColor(dayModel.secondary ? .secondary : Calendar.isDateInWeekend(Calendar.current)(dayModel.id) ? .red : isSelected ? Color.theme.primaryOpposite : .primary)
        }
    }
}

struct DayView_Previews: PreviewProvider {
    static var previews: some View {
        DayView(for: DayModel(id: .now), isSelected: false)
    }
}
