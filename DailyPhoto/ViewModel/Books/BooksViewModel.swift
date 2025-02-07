//
//  BooksViewModel.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/03.
//

import Foundation
import Firebase

class BooksViewModel: ObservableObject {
    @Published var coverImages: [String: String] = [:]
    @Published var sectionDates: [String: (createdAt: Date, date: Date?)] = [:]
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var lockedSections: Set<String> = []

    func fetchCoverImages(uid: String) async {
        do {
            let group = try await FirebaseClient.fetchFirstGroupForUser(userId: uid)
            let groupId = group.id

            let fetchedCoverImages = try await FirebaseClient.fetchCoverImages(groupId: groupId)
            let fetchedDates = try await FirebaseClient.fetchSectionDates(groupId: groupId)

            let (_, lockedSections) = try await FirebaseClient.fetchImagesGroupedBySection(for: uid)

            DispatchQueue.main.async {
                self.coverImages = fetchedCoverImages
                self.sectionDates = fetchedDates
                self.lockedSections = Set(lockedSections)
            }
        } catch {
            print("❌ Error fetching cover images: \(error.localizedDescription)")
        }
    }
}
