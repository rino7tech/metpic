//
//  MainViewModel.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/14.
//

import Foundation

@MainActor
class MainViewModel: ObservableObject {
    @Published var showCalendarView: Bool = true
    @Published var hasTakenPhotoToday: Bool = false
    @Published var showAlert: Bool = false

    func checkDoneStatus(userId: String) async {
        do {
            let hasPendingTasks = try await FirebaseClient.checkDoneStatus(for: userId)
            showCalendarView = !hasPendingTasks
        } catch {
            print("Error checking done status: \(error.localizedDescription)")
            showCalendarView = true
        }
    }

    func checkIfPhotoTakenToday(userId: String) async {
        do {
            let images = try await FirebaseClient.fetchImages(for: userId)
            let today = Calendar.current.startOfDay(for: Date())

            hasTakenPhotoToday = images.contains { image in
                let uploadDate = Calendar.current.startOfDay(for: image.uploadedAt)
                return uploadDate == today && image.capturedBy == userId
            }
        } catch {
            print("Error checking if photo taken today: \(error.localizedDescription)")
            hasTakenPhotoToday = false
        }
    }

    func checkAndUpdateOutdatedSections() async {
        do {
            try await FirebaseClient.updateOutdatedSections()
        } catch {
            print("❌ セクションの更新に失敗しました: \(error.localizedDescription)")
        }
    }
}
