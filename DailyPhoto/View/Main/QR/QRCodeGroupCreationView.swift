//
//  QRCodeGroupCreationView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/03.
//

import SwiftUI

struct QRCodeGroupCreationView: View {
    @Binding var navigateToTabBar: Bool
    @State private var scannedGroupId: String?
    @State private var isScanning = false
    @State private var isLoading = false
    @State private var successMessage: String?
    @State private var errorMessage: String?

    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack {
            if let successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .padding()
            } else {
                Button(action: {
                    isScanning = true
                }) {
                    Text("QRコードをスキャン")
                        .foregroundColor(.customWhite)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }

            if isLoading {
                ProgressView()
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .sheet(isPresented: $isScanning) {
            QRCodeScannerView { scannedValue in
                scannedGroupId = scannedValue
                isScanning = false
                handleScannedGroupId()
            }
        }
    }

    private func handleScannedGroupId() {
        guard let scannedGroupId, let currentUserId = authViewModel.currentUID else {
            errorMessage = "QRコードまたはログイン情報が不正です。"
            return
        }

        Task {
            do {
                isLoading = true
                errorMessage = nil
                try await FirebaseClient.addMemberToGroup(groupId: scannedGroupId, memberId: currentUserId)
                isLoading = false
                successMessage = "グループに参加しました！"

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    navigateToTabBar = true
                }
            } catch {
                isLoading = false
                errorMessage = "グループ参加に失敗しました: \(error.localizedDescription)"
            }
        }
    }
}
