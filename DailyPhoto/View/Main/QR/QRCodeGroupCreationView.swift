//
//  QRCodeGroupCreationView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/03.
//

import SwiftUI

struct QRCodeGroupCreationView: View {
    @Binding var navigateToTabBar: Bool
    @StateObject private var viewModel: QRCodeGroupCreationViewModel

    init(navigateToTabBar: Binding<Bool>, authViewModel: AuthViewModel) {
        self._navigateToTabBar = navigateToTabBar
        self._viewModel = StateObject(wrappedValue: QRCodeGroupCreationViewModel(authViewModel: authViewModel))
    }

    var body: some View {
        VStack {
            if let successMessage = viewModel.successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .padding()
            } else {
                Button(action: {
                    viewModel.startScanning()
                }) {
                    Text("QRコードをスキャン")
                        .foregroundColor(.customWhite)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }

            if viewModel.isLoading {
                ProgressView()
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .sheet(isPresented: $viewModel.isScanning) {
            QRCodeScanner { scannedValue in
                viewModel.handleScannedGroupId(scannedValue)
                if viewModel.successMessage != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        navigateToTabBar = true
                    }
                }
            }
        }
    }
}
