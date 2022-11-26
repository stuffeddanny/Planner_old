//
//  LaunchView.swift
//  Planner
//
//  Created by Danny on 11/25/22.
//

import SwiftUI

struct LaunchView: View {
    
    @Binding var showLaunchView: Bool
    @State private var scale: Double = 1
    @State private var offset: CGSize = CGSize()
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.theme.launchBackground
                .ignoresSafeArea()
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .offset(offset)
                .scaleEffect(scale)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            withAnimation(.easeIn(duration: 0.4)) {
                                showLaunchView = false
                            }
                        }
                        withAnimation(.interpolatingSpring(stiffness: 200, damping: 10)) {
                            scale = 1.3
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                withAnimation(.interpolatingSpring(stiffness: 20, damping: 10)) {
                                    offset = .init(width: 0, height: -UIScreen.main.bounds.height)
                                }
                            }
                        }
                    }
                }
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView(showLaunchView: .constant(true))
    }
}
