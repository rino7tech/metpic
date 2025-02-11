//
//  MainView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/03.
//

import SwiftUI
import Kingfisher

struct MainView: View {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var viewModel = MainViewModel()

    @State private var showCameraView: Bool = false
    @State private var showEditProfileView: Bool = false

    var body: some View {
        NavigationStack {
            if !authViewModel.isLoggedIn {
                SignInView(viewModel: authViewModel)
            } else {
                ZStack {
                    PinkAnimatedMeshView()
                        .ignoresSafeArea()

                    if let uid = authViewModel.currentUID {
                        BooksView(uid: uid)
                            .ignoresSafeArea()
                    }

                    VStack {
                        HStack(alignment: .top) {
                            Button(action: {
                                showEditProfileView.toggle()
                            }) {
                                if let iconURL = authViewModel.profileIconURL, let url = URL(string: iconURL) {
                                    KFImage(url)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.customPink.opacity(0.8), lineWidth: 3))
                                        .shadow(color: .customPink, radius: 5)
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.gray)
                                }
                            }

                            Spacer()
                        }
                        .padding(.all, 20)
                        .padding(.horizontal, 5)

                        Spacer()

                        HStack {
                            Spacer()

                            Button(action: {
                                if !viewModel.hasTakenPhotoToday {
                                    showCameraView.toggle()
                                }
                            }) {
                                Image(systemName: viewModel.hasTakenPhotoToday ? "xmark" : "plus")
                                    .font(.system(size: 24))
                                    .foregroundColor(.customWhite)
                                    .padding()
                                    .background(viewModel.hasTakenPhotoToday ? Color.gray : Color.customPink)
                                    .clipShape(Circle())
                                    .shadow(color: viewModel.hasTakenPhotoToday ? Color.gray : Color.customPink, radius: 5)
                                    .opacity(viewModel.hasTakenPhotoToday ? 0.8 : 1.0)
                            }
                            .disabled(viewModel.hasTakenPhotoToday)
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
                .onAppear {
                    authViewModel.fetchProfile()
                    if let uid = authViewModel.currentUID {
                        Task {
                            await viewModel.checkIfPhotoTakenToday(userId: uid)
                            await viewModel.checkAndUpdateOutdatedSections() 
                        }
                    }
                }
                .fullScreenCover(isPresented: $showEditProfileView) {
                    EditProfileView(authViewModel: authViewModel)
                }
                .fullScreenCover(isPresented: $showCameraView) {
                    SectionSettingView()
                }
            }
        }
    }
}
