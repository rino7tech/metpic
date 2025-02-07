//
//  PageViewModel.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/02/03.
//

import SwiftUI
import Firebase

class PageViewModel: ObservableObject {
    @Published var showActionSheet = false
    @Published var selectedImage: ImageModel?

    func blockUser(currentUserId: String, blockedUserId: String) {
        Task {
            do {
                try await FirebaseClient.blockUser(currentUserId: currentUserId, blockedUserId: blockedUserId)
                print("✅ \(blockedUserId) をブロックしました。")
            } catch {
                print("❌ ブロックに失敗: \(error.localizedDescription)")
            }
        }
    }
}
