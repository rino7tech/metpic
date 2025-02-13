//
//  EditProfileView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/20.
//

import SwiftUI
import PhotosUI
import Kingfisher
import Colorful

struct EditProfileView: View {
    @StateObject private var viewModel: EditProfileViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var focus: Bool
    @State private var showDeleteAlert = false
    @State private var password = ""
    @State private var selectedTab = 0

    init(authViewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: EditProfileViewModel(authViewModel: authViewModel))
    }

    var body: some View {
        ZStack {
            ColorfulView(animation: .easeIn(duration: 1.0), colors: [.customPink, .customLightPink])
                .ignoresSafeArea()

            VStack(spacing: 30) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(viewModel.editProfile ? .gray : .customPink)
                    }
                    .disabled(viewModel.editProfile || viewModel.isLoading)

                    Spacer()

                    Button(action: {
                        viewModel.editProfile.toggle()
                    }) {
                        Text(viewModel.editProfile ? "キャンセル" : "編集")
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    .disabled(viewModel.isLoading)
                    .opacity(selectedTab == 0 ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                }
                .padding(.horizontal)

                TabView(selection: $selectedTab) {
                    profileEditView
                        .tag(0)

                    GroupMembersView()
                        .tag(1)
                        .transition(.slide)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .animation(.easeInOut, value: selectedTab)

                VStack {
                    if selectedTab == 0 {
                        actionButtons
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: selectedTab)
                    } else {
                        Spacer()
                            .frame(height: 80)
                    }
                }
            }
            .padding(.vertical, 20)

            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .onAppear {
            viewModel.fetchProfile()
        }
        .onTapGesture {
            focus = false
        }
    }

    private var profileEditView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.customWhite.opacity(0.3))
                .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 5)
                .padding(.horizontal)
                .blur(radius: 0.1)

            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    PhotosPicker(selection: $viewModel.selectedPhoto) {
                        if let image = viewModel.selectedUIImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            KFImage(URL(string: viewModel.imageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        }
                    }
                    .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
                    .onChange(of: viewModel.selectedPhoto) { _, newValue in
                        viewModel.selectPhoto(newValue: newValue)
                    }
                    .disabled(!viewModel.editProfile || viewModel.isLoading)
                }

                VStack(spacing: 30) {
                    TextField("Name", text: $viewModel.newName)
                        .padding()
                        .background(Color.customWhite.opacity(0.7).blur(radius: 0.05))
                        .cornerRadius(15)
                        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)
                        .disabled(!viewModel.editProfile || viewModel.isLoading)
                }
                .padding(.horizontal, 20)
                .focused($focus)
            }
            .padding()
        }
        .padding(.horizontal, 10)
    }

    private var actionButtons: some View {
        VStack {
            if viewModel.editProfile {
                Button(action: {
                    viewModel.saveProfile()
                }) {
                    Text("保存")
                        .fontWeight(.bold)
                        .foregroundColor(.customWhite)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.hasChanges ? Color.customPink : Color.gray)
                        .cornerRadius(15)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.hasChanges)
                }
                .padding(.horizontal, 50)
                .disabled(!viewModel.hasChanges || viewModel.isLoading)
            } else {
                Button(action: {
                    viewModel.logout()
                    dismiss()
                }) {
                    Text("サインアウト")
                        .fontWeight(.bold)
                        .foregroundColor(.customWhite)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.customPink)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 50)
                .disabled(viewModel.isLoading)

                Button(action: {
                    showDeleteAlert = true
                }) {
                    Text("アカウント削除")
                        .font(.footnote)
                        .foregroundColor(.red)
                }
                .padding(.top, 5)
                .alert("Enter Password to Delete Account", isPresented: $showDeleteAlert) {
                    SecureField("Password", text: $password)
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        viewModel.deleteAccount(password: password)
                    }
                } message: {
                    Text("Please enter your password to delete your account.")
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: viewModel.editProfile)
        .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
        .zIndex(-5)
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.customWhite.opacity(0.2).ignoresSafeArea()
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .customWhite))
                    .scaleEffect(1.5)
                    .padding()
            }
            .frame(width: 150, height: 150)
            .cornerRadius(15)
        }
        .transition(.opacity)
    }
}
