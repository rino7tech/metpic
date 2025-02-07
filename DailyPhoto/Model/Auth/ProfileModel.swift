//
//  ProfileModel.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/02.
//

import Foundation
import FirebaseFirestore

struct ProfileModel: Codable, Identifiable {
    var id: String 
    let name: String
    var iconURL: String?
    let createdAt: Date

    var encoded: [String: Any] {
        get throws {
            try Firestore.Encoder().encode(self)
        }
    }
}
