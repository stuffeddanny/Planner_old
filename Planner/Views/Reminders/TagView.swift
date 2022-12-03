//
//  TagView.swift
//  Planner
//
//  Created by Danny on 12/3/22.
//

import SwiftUI

struct TagView: View {
    
    let tag: Tag
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .foregroundColor(tag.color)
                .padding(.vertical, 5)
            
            Text(tag.text)
        }
        .padding(.horizontal, 7)
        .background(
            Rectangle()
                .cornerRadius(15)
                .foregroundColor(isSelected ? tag.color.opacity(0.6) : .secondary.opacity(0.5))
        )
        
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView(tag: Tag(text: "Test", color: .pink), isSelected: false)
            .frame(height: 30)
    }
}
