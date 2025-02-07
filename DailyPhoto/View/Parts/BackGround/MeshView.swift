//
//  MeshView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/04.
//

import SwiftUI

struct MeshView: View {
    @State private var animatedGradient = false

    var body: some View {
        LinearGradient(colors: [.customLightPink.opacity(0.5), .customPink], startPoint: .topLeading, endPoint: .bottomTrailing)
            .hueRotation(.degrees(animatedGradient ? 45 : 0))
            .ignoresSafeArea()
            .onAppear { withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: true))
                {
                    animatedGradient.toggle()
                }
            }
    }
}

#Preview {
    MeshView()
}
