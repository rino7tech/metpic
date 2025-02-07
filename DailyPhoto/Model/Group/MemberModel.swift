//
//  MemberModel.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/12.
//

import Foundation
import FirebaseFirestore

struct MemberModel: Codable, Identifiable {
    var id: String
    let name: String
    let iconUrl: String?
    let joinedAt: Date

    var encoded: [String: Any] {
        get throws {
            try Firestore.Encoder().encode(self)
        }
    }
}
