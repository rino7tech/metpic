//
//  QRCodeGroupCreationViewModel.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/02/09.
//

import SwiftUI

class QRCodeGroupCreationViewModel: ObservableObject {
    @Published var scannedGroupId: String?
    @Published var isScanning = false
    @Published var isLoading = false
    @Published var successMessage: String?
    @Published var errorMessage: String?

    private let authViewModel: AuthViewModel

    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }

    func startScanning() {
        isScanning = true
    }

    func handleScannedGroupId(_ scannedValue: String?) {
        guard let scannedGroupId = scannedValue, let currentUserId = authViewModel.currentUID else {
            errorMessage = "QRコードまたはログイン情報が不正です。"
            return
        }

        isScanning = false
        self.scannedGroupId = scannedGroupId
        addMemberToGroup(groupId: scannedGroupId, memberId: currentUserId)
    }

    private func addMemberToGroup(groupId: String, memberId: String) {
        Task {
            do {
                DispatchQueue.main.async {
                    self.isLoading = true
                    self.errorMessage = nil
                }
                
                try await FirebaseClient.addMemberToGroup(groupId: groupId, memberId: memberId)

                DispatchQueue.main.async {
                    self.isLoading = false
                    self.successMessage = "グループに参加しました！"
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "グループ参加に失敗しました: \(error.localizedDescription)"
                }
            }
        }
    }
}
