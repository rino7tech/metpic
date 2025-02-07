//
//  GroupModel.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/03.
//

import Foundation
import FirebaseFirestore

struct GroupModel: Codable {
    let id: String
    let name: String
    let createdAt: Date
    let members: [String]

    var encoded: [String: Any] {
        get throws {
            try Firestore.Encoder().encode(self)
        }
    }
}
