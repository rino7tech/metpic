//
//  SectionSettingViewModel.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/14.
//

import Foundation
import FirebaseAuth
import PhotosUI

@MainActor
class SectionSettingViewModel: ObservableObject {
    @Published var selectedDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    @Published var saveMessage: String? = nil
    @Published var isDateSaved: Bool = false
    @Published var selectedCoverImageData: Data? = nil

    func saveSelectedDate() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.saveMessage = "認証されていません"
            return
        }

        do {
            let group = try await FirebaseClient.fetchFirstGroupForUser(userId: currentUserId)
            let groupId = group.id
            let sectionId = UUID().uuidString

            var coverImageUrl: String? = nil
            if let imageData = selectedCoverImageData {
                coverImageUrl = try await FirebaseClient.uploadCoverImage(data: imageData, groupId: groupId, sectionId: sectionId)
            }

            try await FirebaseClient.saveSelectedDate(
                groupId: groupId,
                sectionId: sectionId,
                date: selectedDate,
                coverImageUrl: coverImageUrl
            )

            self.saveMessage = "日付を保存しました！ (グループ: \(group.name), セクションID: \(sectionId))"

            await checkIfUnfinishedSectionsExist()
        } catch {
            self.saveMessage = "日付の保存に失敗しました: \(error.localizedDescription)"
        }
    }

    func checkIfUnfinishedSectionsExist() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            return
        }

        do {
            let hasUnfinishedSections = try await FirebaseClient.checkDoneStatus(for: currentUserId)
            self.isDateSaved = hasUnfinishedSections
        } catch {
            self.isDateSaved = false
        }
    }
}
