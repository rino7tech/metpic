//
//  PageView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/25.
//

import SwiftUI
import Kingfisher

struct PageView: View {
    let images: [ImageModel]
    @State private var currentPage: Int = 0
    @StateObject private var viewModel = PageViewModel()

    @AppStorage("userId") private var userId: String = ""

    private var groupedImages: [(date: String, images: [ImageModel])] {
        Dictionary(grouping: images) { image in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd.EEE"
            return formatter.string(from: image.uploadedAt)
        }
        .sorted { $0.key > $1.key }
        .map { (date: $0.key, images: $0.value) }
    }

    var body: some View {
        if groupedImages.isEmpty {
            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 8, topTrailingRadius: 8, style: .continuous)
                .frame(width: 180, height: 264)
                .foregroundStyle(.customWhite)
        } else {
            ZStack {
                UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 8, topTrailingRadius: 8, style: .continuous)
                    .frame(width: 180, height: 264)
                    .foregroundStyle(.customWhite)

                TabView(selection: $currentPage) {
                    ForEach(groupedImages.indices, id: \.self) { index in
                        VStack(spacing: 10) {
                            let images = groupedImages[index].images

                            ForEach(images.indices, id: \.self) { i in
                                KFImage(URL(string: images[i].url))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 140, height: 100)
                                    .clipped()
                                    .cornerRadius(8)
                                    .onLongPressGesture {
                                        viewModel.selectedImage = images[i]
                                        viewModel.showActionSheet = true
                                    }

                                if i == 0 {
                                    Text(groupedImages[index].date)
                                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                                        .foregroundColor(.CustomBlack)
                                }
                            }
                        }
                        .tag(index)
                    }
                }
                .frame(width: 180, height: 264)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width < -50 {
                                currentPage = min(currentPage + 1, groupedImages.count - 1)
                            } else if value.translation.width > 50 {
                                currentPage = max(currentPage - 1, 0)
                            }
                        }
                )
                .actionSheet(isPresented: $viewModel.showActionSheet) {
                    ActionSheet(
                        title: Text("オプション"),
                        message: Text("この画像の投稿者をブロックまたは通報しますか？"),
                        buttons: [
                            .destructive(Text("ブロック")) {
                                if let image = viewModel.selectedImage {
                                    viewModel.blockUser(currentUserId: userId, blockedUserId: image.capturedBy)
                                }
                            },
                            .default(Text("通報")) {
                                if let url = URL(string: "https://forms.gle/sbTcRmH9K9BfrKzd7") {
                                    UIApplication.shared.open(url)
                                }
                            },
                            .cancel()
                        ]
                    )
                }
            }
        }
    }
}
