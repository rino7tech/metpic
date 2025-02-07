//
//  ContentView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/02.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var hasAcceptedTerms = UserDefaults.standard.bool(forKey: "hasAcceptedTerms")

    var body: some View {
        ZStack {
            if !hasAcceptedTerms {
                PolicyView(hasAcceptedTerms: $hasAcceptedTerms)
            } else if authViewModel.isLoading {
                FirstLoadingView()
            } else {
                if authViewModel.navigateToMainView {
                    MainView()
                } else if authViewModel.navigateToQRCodeView {
                    MainQRCodeView()
                } else {
                    SignInView(viewModel: authViewModel)
                }
            }
        }
        .onAppear {
            authViewModel.checkUserStatus()
        }
    }
}
