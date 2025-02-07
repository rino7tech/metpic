//
//  AnimatedMeshView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/04.
//

import SwiftUI

struct PinkAnimatedMeshView: View {
    @State var start = UnitPoint(x: 0, y: -2)
    @State var end = UnitPoint(x: 4, y: 0)

    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    let colors = [Color.customPink.opacity(0.7),Color.customLightPink.opacity(0.5)]

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: colors), startPoint: start, endPoint: end)
                .animation(Animation.easeInOut(duration: 6)
                    .repeatForever()
                ).onReceive(timer, perform: { _ in
                    self.start = UnitPoint(x: 4, y: 0)
                    self.end = UnitPoint(x: 0, y: 2)
                    self.start = UnitPoint(x: -4, y: 20)
                    self.start = UnitPoint(x: 4, y: 0)
                })
        }
        .ignoresSafeArea()
        .blur(radius: 50)
    }
}

struct LightPinkAnimatedMeshView: View {
    @State var start = UnitPoint(x: 0, y: -2)
    @State var end = UnitPoint(x: 4, y: 0)

    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    let colors = [Color.customPink.opacity(0.6),Color.customLightPink.opacity(0.4)]

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: colors), startPoint: start, endPoint: end)
                .animation(Animation.easeInOut(duration: 6)
                    .repeatForever()
                ).onReceive(timer, perform: { _ in
                    self.start = UnitPoint(x: 4, y: 0)
                    self.end = UnitPoint(x: 0, y: 2)
                    self.start = UnitPoint(x: -4, y: 20)
                    self.start = UnitPoint(x: 4, y: 0)
                })
        }
        .ignoresSafeArea()
        .blur(radius: 50)
    }
}


#Preview {
    PinkAnimatedMeshView()
}
