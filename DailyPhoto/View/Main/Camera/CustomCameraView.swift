//
//  HomeView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/02.
//

import SwiftUI

struct CustomCameraView: View {
    @StateObject private var viewModel = CustomCameraViewModel()
    @State private var takePhoto = false
    @State private var capturedImage: UIImage?
    @State private var flashEnabled = false
    @State private var showPreview = true
    @State private var formattedDate: String = DateManager.getFormattedDate()
    @State private var isUsingFrontCamera = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            LightPinkAnimatedMeshView()
                .ignoresSafeArea()

            VStack(spacing: 20) {

                ZStack {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray.opacity(0.8))
                                .padding()
                        }
                        Spacer()
                    }
                    Text(formattedDate)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.customPink.opacity(0.8))
                        .padding(.top, 10)
                        .shadow(color: .customPink.opacity(0.4), radius: 2, x: 0, y: 2)
                }
                if showPreview {
                    Camera(
                        takePhoto: $takePhoto,
                        capturedImage: $capturedImage,
                        showPreview: $showPreview,
                        flashEnabled: $flashEnabled,
                        isUsingFrontCamera: $isUsingFrontCamera
                    )
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.9 * 3 / 4)
                    .cornerRadius(20)
                    .shadow(color: .gray.opacity(0.5), radius: 1)
                    .onAppear {
                        takePhoto = false
                    }
                } else if let image = capturedImage {
                    VStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.9 * 3 / 4)
                            .clipped()
                            .cornerRadius(20)
                            .shadow(color: .gray.opacity(0.5), radius: 1)

                        HStack(spacing: 120) {
                            Button(action: {
                                withAnimation {
                                    showPreview = true
                                    capturedImage = nil
                                }
                            }) {
                                Image(systemName: "arrow.uturn.left")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.gray)
                            }
                            Button(action: {
                                Task {
                                    await viewModel.saveImage(image: image)
                                    withAnimation {
                                        showPreview = true
                                        capturedImage = nil
                                    }

                                    presentationMode.wrappedValue.dismiss()
                                }
                            }) {
                                Text(viewModel.isSaving ? "保存中" : "保存")
                                    .font(.title3)
                                    .bold()
                                    .padding()
                                    .frame(width: 180)
                                    .background(LinearGradient(gradient: Gradient(colors: [Color.customPink, Color.customLightPink.opacity(0.5)]), startPoint: .bottomLeading, endPoint: .topLeading))
                                    .foregroundColor(.customWhite)
                                    .cornerRadius(25)
                                    .shadow(color: Color.black.opacity(0.4), radius: 5, x: 0, y: 3)
                            }
                            .disabled(viewModel.isSaving)
                        }
                        .padding(.top, 15)
                    }
                }

                if showPreview {
                    HStack(spacing: 80) {
                        Button(action: {
                            withAnimation {
                                flashEnabled.toggle()
                            }
                        }) {
                            Image(systemName: flashEnabled ? "bolt.fill" : "bolt.slash.fill")
                                .font(.system(size: 28))
                                .foregroundColor( .gray)
                        }

                        Button(action: {
                            takePhoto = true
                        }) {
                            Circle()
                                .frame(width: 70, height: 70)
                                .foregroundColor(.customWhite)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.4), lineWidth: 3)
                                )
                        }
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)

                        Button(action: {
                            withAnimation {
                                isUsingFrontCamera.toggle()
                            }
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    CustomCameraView()
}
