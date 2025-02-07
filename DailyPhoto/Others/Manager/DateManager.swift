//
//  DateManager.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/18.
//

import Foundation

class DateManager {
    static func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd.EEE"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: Date())
    }
}
