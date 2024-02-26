//
//  LoadingAnimationView.swift
//  AI Podcast Stream
//
//  Created by Maksym Bidnyi on 18.02.2024.
//

import SwiftUI

struct LoadingAnimation: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: geometry.size.width * 0.85, height: 8)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(Color.blue.opacity(0.8))
                    .frame(width: (animate ? geometry.size.width * 0.85 : 0), height: 8)
                    .cornerRadius(4)
                    .animation(Animation.linear(duration: 10).repeatForever(autoreverses: false), value: animate)
            }
            // Center the ZStack horizontally by adjusting its frame
            .frame(width: geometry.size.width, height: geometry.size.height)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // Positioning it in the center
            .onAppear {
                self.animate = true
            }
        }
    }
}

#Preview {
    LoadingAnimation()
}
