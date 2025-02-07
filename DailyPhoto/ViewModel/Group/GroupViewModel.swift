//
//  GroupViewModel.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/03.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class GroupViewModel: ObservableObject {
    @Published var groupName: String? = nil
    @Published var members: [MemberModel] = []
    @Published var errorMessage: String? = nil

    func fetchFirstGroupAndMembers() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.errorMessage = "認証されていません"
            }
            return
        }

        do {
            let group = try await FirebaseClient.fetchFirstGroupForUser(userId: currentUserId)

            DispatchQueue.main.async {
                self.groupName = group.name
            }

            let members = try await FirebaseClient.fetchMembers(for: group.members)
            DispatchQueue.main.async {
                self.members = members
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func blockUser(memberId: String) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "認証されていません"
            return
        }

        do {
            try await FirebaseClient.blockUser(currentUserId: currentUserId, blockedUserId: memberId)

            DispatchQueue.main.async {
                self.members.removeAll { $0.id == memberId }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
