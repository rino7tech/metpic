//
//  MainQRCodeView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/03.
//

import SwiftUI
import Colorful

struct MainQRCodeView: View {
    @State private var isShowingQRCodeGenerator = false
    @State private var isShowingQRCodeScanner = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var showResultModal = false
    @State private var navigateToCustomTab = false
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            if navigateToCustomTab {
                MainView()
            } else {
                ZStack {
                    ColorfulView(animation: .easeInOut(duration: 0.5), colors: [.customPink, .customLightPink.opacity(0.5)])
                        .ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.customWhite.opacity(0.6))
                            .frame(width: UIScreen.main.bounds.width * 0.93, height: UIScreen.main.bounds.height * 0.57)
                            .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 5)
                        Spacer()
                    }
                    
                    VStack(spacing: 20) {
                        Spacer()
                        Text("グループを作成しよう")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.customPink)
                            .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 3)
                            .padding(.bottom, 10)
                        
                        Text("グループを作成するか、\n グループに参加してください。")
                            .font(.body)
                            .foregroundColor(.customPink)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 20)
                        
                        Button(action: {
                            isShowingQRCodeGenerator = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.customWhite)
                                Text("グループを作成する")
                                    .font(.headline)
                                    .foregroundColor(.customWhite)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.customPink, Color.customLightPink]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(25)
                            .shadow(color: Color.customPink.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 32)
                        
                        Button(action: {
                            isShowingQRCodeScanner = true
                        }) {
                            HStack {
                                Image(systemName: "person.3.fill")
                                    .font(.title)
                                    .foregroundColor(.customPink)
                                Text("グループに参加する")
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
                        .padding(.horizontal, 32)
                        .sheet(isPresented: $isShowingQRCodeScanner) {
                            QRCodeScannerView { scannedValue in
                                isShowingQRCodeScanner = false
                                handleScannedGroupId(scannedGroupId: scannedValue)
                            }
                            .presentationDetents([
                                .height(450)
                            ])
                            .presentationDragIndicator(.visible)
                        }
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .customWhite))
                                .scaleEffect(1.5)
                                .padding()
                        }
                        Spacer()
                    }
                    .sheet(isPresented: $isShowingQRCodeGenerator) {
                        QRCodeGeneratorView()
                            .environmentObject(authViewModel)
                            .presentationDetents([
                                .height(450)
                            ])
                            .presentationDragIndicator(.visible)
                    }
                    .alert(isPresented: $showResultModal) {
                        if let successMessage {
                            return Alert(
                                title: Text("成功"),
                                message: Text(successMessage),
                                dismissButton: .default(Text("OK"), action: {
                                    navigateToCustomTab = true
                                })
                            )
                        } else {
                            return Alert(
                                title: Text("エラー"),
                                message: Text(errorMessage ?? "不明なエラーが発生しました。"),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                    .onAppear {
                        checkUserMembership()
                    }
                }
            }
        }
    }
    
    private func checkUserMembership() {
        guard let currentUserId = authViewModel.currentUID else {
            errorMessage = "ログインが必要です。"
            showResultModal = true
            return
        }
        
        Task {
            do {
                isLoading = true
                errorMessage = nil
                let isMember = try await FirebaseClient.isUserInAnyGroup(userId: currentUserId)
                isLoading = false
                
                if isMember {
                    successMessage = "グループに所属しています！"
                } else {
                    errorMessage = "どのグループにも所属していません。"
                }
                showResultModal = true
            } catch {
                isLoading = false
                errorMessage = "エラーが発生しました: \(error.localizedDescription)"
                showResultModal = true
            }
        }
    }
    
    private func handleScannedGroupId(scannedGroupId: String) {
        guard let currentUserId = authViewModel.currentUID else {
            errorMessage = "ログインが必要です。"
            showResultModal = true
            return
        }
        
        Task {
            do {
                isLoading = true
                errorMessage = nil
                try await FirebaseClient.addMemberToGroup(groupId: scannedGroupId, memberId: currentUserId)
                isLoading = false
                successMessage = "グループに参加しました！"
                showResultModal = true
            } catch {
                isLoading = false
                errorMessage = "グループ参加に失敗しました: \(error.localizedDescription)"
                showResultModal = true
            }
        }
    }
}
