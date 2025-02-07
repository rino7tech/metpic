//
//  ImageGalleryView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/25.
//

import SwiftUI
import Kingfisher

struct ImageGalleryView: View {
    @StateObject private var viewModel = ImageGalleryViewModel()
    let uid: String
    let sectionId: String

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading images...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else if !viewModel.images.isEmpty {
                    ScrollView {
                        LazyVStack {
                            ForEach(viewModel.images, id: \.self) { image in
                                KFImage(URL(string: image.url))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 300, height: 200)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                    .padding()
                            }
                        }
                    }
                } else {
                    Text("No images found.")
                }
            }
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        viewModel.dismiss()
                    }
                }
            }
            .task {
                await viewModel.fetchImages(uid: uid, sectionId: sectionId)
            }
        }
    }
}
