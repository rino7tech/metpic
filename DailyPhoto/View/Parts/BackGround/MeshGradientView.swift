//
//  MeshGradientView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/06.
//

import SwiftUI

struct PinkMeshGradientView: View {
    @State private var isAnimating = false
    var body: some View {
        ZStack {
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0.0, 0.0],[0.5, 0.0],[1.0, 0.0],
                    [0.0, 0.5],[0.9, 0.3],[1.0, 0.5],
                    [0.0, 1.0],[0.5, 1.0],[1.0, 1.0]
                ],
                colors: [.customPink,.customLightPink,.customPink.opacity(0.3),.customLightPink.opacity(0.3),.customPink,.customLightPink,.customPink.opacity(0.3),.customPink.opacity(0.3),.customPink,.customLightPink,.customPink.opacity(0.3),.customLightPink.opacity(0.3)]
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                    isAnimating.toggle()
                }
            }
            .background(Color.customWhite)
        }
        .blur(radius: 0.1)
        .ignoresSafeArea()
    }
}

#Preview {
    PinkMeshGradientView()
}
