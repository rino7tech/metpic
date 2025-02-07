//
//  DateFormatter.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/12.
//
import SwiftUI

extension DateFormatter {
    static var shortDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
}
