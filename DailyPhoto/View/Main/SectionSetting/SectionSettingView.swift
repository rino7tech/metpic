//
//  SectionSettingView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/13.
//

import SwiftUI
import PhotosUI
import Colorful

struct SectionSettingView: View {
    @StateObject private var viewModel = SectionSettingViewModel()
    @State private var isLoading = true
    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    ProgressView("読み込み中…")
                        .font(.headline)
                        .padding()
                } else if viewModel.isDateSaved {
                    CustomCameraView()
                        .ignoresSafeArea()
                } else {
                    ZStack {
                        ColorfulView(animation: .easeInOut(duration: 0.5), colors: [.customPink, .customLightPink.opacity(0.5)])
                            .ignoresSafeArea()
                        VStack(spacing: 20) {
                            Text("開封日を設定してください")
                                .font(.title2.bold())

                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.customWhite.opacity(0.45))
                                    .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 5)
                                    .blur(radius: 0.1)
                                    .frame(width: 390, height: 380)
                                VStack {
                                    DatePicker(
                                        "日付を選択",
                                        selection: $viewModel.selectedDate,
                                        in: Calendar.current.date(byAdding: .day, value: 1, to: Date())!...,
                                        displayedComponents: [.date]
                                    )
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .padding()
                                    .accentColor(.customPink)

                                }
                            }
                            .scaleEffect(0.95)


                            NavigationLink(destination: ImageSettingView(viewModel: viewModel)) {
                                Text("次へ")
                                    .font(.headline)
                                    .foregroundColor(.customWhite)
                                    .fontWeight(.bold)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(LinearGradient(gradient: Gradient(colors: [Color.customPink, Color.customLightPink.opacity(0.5)]), startPoint: .bottomLeading, endPoint: .topLeading))
                                    .cornerRadius(25)
                                    .shadow(color: Color.customPink.opacity(0.5), radius: 10, x: 0, y: 5)
                            }
                            .padding()
                        }
                        .padding()
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                    }
                }
            }
            .task {
                isLoading = true
                await viewModel.checkIfUnfinishedSectionsExist()
                isLoading = false
            }
        }
    }
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
