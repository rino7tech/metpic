//
//  DataSaveView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/26.
//

import SwiftUI
import PhotosUI
import Colorful

struct ImageSettingView: View {
    @ObservedObject var viewModel: SectionSettingViewModel
    @State private var selectedItem: PhotosPickerItem? = nil
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            ColorfulView(animation: .easeInOut(duration: 0.5), colors: [.customPink, .customLightPink.opacity(0.5)])
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("サムネイルを設定してください")
                    .font(.title2.bold())
                ZStack {
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        ZStack {
                            if let imageData = viewModel.selectedCoverImageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 330, height: 440)
                                    .clipped()
                                    .cornerRadius(8)
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.customWhite.opacity(0.45))
                                        .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 5)
                                        .blur(radius: 0.1)
                                        .frame(width: 330, height: 440)
                                    Image(systemName: "plus")
                                        .font(.title)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data)?.croppedToAspectRatio(3, 4),
                               let croppedData = image.jpegData(compressionQuality: 0.8) {
                                viewModel.selectedCoverImageData = croppedData
                            }
                        }
                    }
                }

                VStack(spacing: 20) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.customPink)
                            Text("開封日設定へ戻る")
                                .font(.headline)
                                .foregroundColor(.customPink)
                                .fontWeight(.bold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.customWhite.opacity(0.8))
                        .cornerRadius(25)
                        .shadow(color: Color.customPink.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    Button(action: {
                        Task {
                            await viewModel.saveSelectedDate()
                            dismiss()
                        }
                    }) {
                        Text("保存")
                            .font(.headline)
                            .foregroundColor(.customWhite)
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.customPink, Color.customLightPink.opacity(0.5)]), startPoint: .bottomLeading, endPoint: .topLeading))
                            .cornerRadius(25)
                            .shadow(color: Color.customPink.opacity(0.5), radius: 10, x: 0, y: 5)
                    }

                    if let message = viewModel.saveMessage {
                        Text(message)
                            .foregroundColor(message.contains("失敗") ? .red : .green)
                    }
                }
                .padding()
            }
            .padding()
        }
        .navigationBarBackButtonHidden()
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
