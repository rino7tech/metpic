//
//  SignUpProfileContent.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/16.
//

import SwiftUI
import _PhotosUI_SwiftUI
import Colorful
import PhotosUI

struct SignUpProfileView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var isUsernameFocused: Bool = false
    @State private var selectedImageData: Data?
    @State private var selectedImage: UIImage?
    @State private var isPhotoPickerPresented = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var showErrorAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                ColorfulView(animation: .easeInOut(duration: 0.5), colors: [.customPink, .customLightPink.opacity(0.5)])
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.customWhite.opacity(0.5))
                        .frame(width: UIScreen.main.bounds.width * 0.93, height: UIScreen.main.bounds.height * 0.57)
                        .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 5)
                    Spacer()
                }

                VStack(spacing: 20) {
                    Text("Profile")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.customPink)
                        .padding(.bottom, 10)

                    VStack(spacing: 16) {
                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.customWhite, lineWidth: 2))
                                .onTapGesture {
                                    isPhotoPickerPresented = true
                                }
                        } else {
                            Circle()
                                .fill(Color.customWhite.opacity(0.8))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "plus")
                                        .foregroundColor(.gray)
                                )
                                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                                .onTapGesture {
                                    isPhotoPickerPresented = true
                                }
                        }

                        TextField("名前", text: $viewModel.name)
                            .padding()
                            .background(Color.customWhite.opacity(0.8))
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 20)

                    Button(action: {
                        viewModel.signUp()
                    }) {
                        Text("アカウント登録")
                            .font(.headline)
                            .foregroundColor(.customWhite)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.customPink, Color.customLightPink.opacity(0.5)]), startPoint: .bottomLeading, endPoint: .topLeading))
                            .cornerRadius(25)
                            .shadow(color: Color.customPink.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 32)
                }
            }
            .navigationBarBackButtonHidden(true)
            .photosPicker(isPresented: $isPhotoPickerPresented, selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let newItem = newItem {
                        do {
                            if let data = try await newItem.loadTransferable(type: Data.self) {
                                selectedImageData = data
                                selectedImage = UIImage(data: data)
                                viewModel.iconData = data
                            }
                        } catch {
                            print("画像の読み込みに失敗: \(error)")
                        }
                    }
                }
            }
            .alert("エラー", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
        .fullScreenCover(isPresented: $viewModel.shouldNavigate) {
            if viewModel.isLoggedIn {
                MainQRCodeView()
            }
        }
        .onChange(of: viewModel.errorMessage) { newError in
            if !newError.isEmpty {
                showErrorAlert = true
            }
        }
    }
}

#Preview {
    SignUpProfileView(viewModel: .init())
}
