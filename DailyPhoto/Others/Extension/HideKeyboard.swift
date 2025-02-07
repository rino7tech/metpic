//
//  File.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/31.
//
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
