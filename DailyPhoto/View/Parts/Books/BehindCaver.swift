//
//  BehindCaver.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/27.
//

import SwiftUI

struct BehindCaver : View {
    @Binding var show2: Bool
    @Binding var close: Bool

    var body: some View {
        ZStack {
            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 8, topTrailingRadius: 8, style: .continuous)
            .frame(width: 180, height: 264)
            .foregroundStyle(.customWhite)
            .rotation3DEffect(.degrees(-180), axis: (x: 0, y: 1, z: 0))
        }
        .rotation3DEffect(
            .degrees( show2 ? -180 : 0),
            axis: (x: 0, y: 1, z: 0),
            anchor: .leading,
            anchorZ: 0,
            perspective: 0.3
        )
        .opacity(close ? 0 : 1)
    }
}
