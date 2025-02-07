//
//  HomeViewModel.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/03.
//

import Foundation
import FirebaseAuth
import SwiftUI

class CustomCameraViewModel: ObservableObject {
    @Published var errorMessage: String = ""
    @Published var isSaving: Bool = false

    func saveImage(image: UIImage) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.errorMessage = "ユーザーIDが見つかりません。"
            return
        }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            self.errorMessage = "画像データの変換に失敗しました。"
            return
        }

        do {
            self.isSaving = true
            let successMessage = try await FirebaseClient.saveImageToGroupSection(imageData: imageData, userId: uid)
            DispatchQueue.main.async {
                self.errorMessage = successMessage
                self.isSaving = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "画像保存エラー: \(error.localizedDescription)"
                self.isSaving = false
            }
        }
    }
}
