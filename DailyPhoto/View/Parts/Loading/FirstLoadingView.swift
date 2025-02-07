//
//  FirstLoadingView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/29.
//

import SwiftUI

struct FirstLoadingView: View {
    var body: some View {
        ZStack {
            PinkMeshGradientView()
            Image("Icon")
                .scaleEffect(0.25)
        }
    }
}
