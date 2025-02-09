//
//  MainQRCodeViewModel.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/02/09.
//


import SwiftUI

class MainQRCodeViewModel: ObservableObject {
    @Published var isShowingQRCodeGenerator = false
    @Published var isShowingQRCodeScanner = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var showResultModal = false
    @Published var navigateToCustomTab = false

    private let authViewModel: AuthViewModel

    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }

    func checkUserMembership() {
        guard let currentUserId = authViewModel.currentUID else {
            errorMessage = "ログインが必要です。"
            showResultModal = true
            return
        }

        Task {
            do {
                DispatchQueue.main.async { self.isLoading = true }
                let isMember = try await FirebaseClient.isUserInAnyGroup(userId: currentUserId)
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    if isMember {
                        self.successMessage = "グループに所属しています！"
                    } else {
                        self.errorMessage = "どのグループにも所属していません。"
                    }
                    self.showResultModal = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "エラーが発生しました: \(error.localizedDescription)"
                    self.showResultModal = true
                }
            }
        }
    }

    func handleScannedGroupId(scannedGroupId: String) {
        guard let currentUserId = authViewModel.currentUID else {
            errorMessage = "ログインが必要です。"
            showResultModal = true
            return
        }

        Task {
            do {
                DispatchQueue.main.async { self.isLoading = true }
                try await FirebaseClient.addMemberToGroup(groupId: scannedGroupId, memberId: currentUserId)

                DispatchQueue.main.async {
                    self.isLoading = false
                    self.successMessage = "グループに参加しました！"
                    self.showResultModal = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "グループ参加に失敗しました: \(error.localizedDescription)"
                    self.showResultModal = true
                }
            }
        }
    }
}