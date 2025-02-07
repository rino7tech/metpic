//
//  IsometricImageView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/27.
//

import SwiftUI
import Kingfisher

struct IsometricImageView: View {
    let imageUrl: String

    var body: some View {
        IsometricView(depth: 5) {
            KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 200)
                .clipped()
                .clipShape(CustomCornerShape(radius: 6))
        } bottom: {
            Color.gray.opacity(0.2)
                .clipShape(CustomCornerShape(radius: 10))
        } side: {
            Color.gray.opacity(0.2)
                .clipShape(CustomCornerShape(radius: 6))
        }
        .frame(width: 150, height: 200)
    }
}
