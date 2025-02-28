//
//  ImageModel.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/03.
//

import Foundation
import FirebaseFirestore

struct ImageModel: Codable, Hashable {
    @DocumentID var id: String?
    let url: String
    let uploadedAt: Date
    let capturedBy: String

    var encoded: [String: Any] {
        get throws {
            try Firestore.Encoder().encode(self)
        }
    }
}
