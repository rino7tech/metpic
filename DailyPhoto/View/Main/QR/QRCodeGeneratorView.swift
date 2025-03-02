//
//  QRCodeGeneratorView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/03.
//

import SwiftUI
import FirebaseAuth

struct QRCodeGeneratorView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = QRCodeGeneratorViewModel()
    @Binding var navigateToCustomTab: Bool
    var isPresentedFromGroupMembers: Bool
    @State private var qrImage: UIImage?
    @State private var isShareSheetPresented = false

    var body: some View {
        ZStack {
            PinkMeshGradientView()
                .ignoresSafeArea()
                .blur(radius: 0.1)

            VStack(spacing: 0) {
                if let currentUID = authViewModel.currentUID {
                    Text("QRコード共有")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.customWhite)
                        .padding(.top, 50)

                    Spacer()

                    if let qrCodeContent = viewModel.generatedGroupId,
                       let qrImage = viewModel.generateQRCode(from: qrCodeContent) {
                        ZStack {
                            Image(uiImage: qrImage)
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 230, height: 230)
                                .padding(20)
                                .background(Color.customWhite.opacity(0.7).blur(radius: 0.3))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.customPink, lineWidth: 5)
                                )
                        }
                        .padding()
                        .onAppear {
                            self.qrImage = qrImage
                        }
                    } else if viewModel.isSaving {
                        ProgressView("QRコードを生成中...")
                            .padding()
                    } else {
                        Text("QRコードの生成に失敗しました")
                            .foregroundColor(.red)
                    }

                    Spacer()

                    if let qrImage = qrImage {
                        Button(action: {
                            isShareSheetPresented = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundStyle(Color.customPink)
                                Text("共有")
                                    .font(.headline)
                                    .foregroundColor(.customPink)
                                    .fontWeight(.bold)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.customWhite.opacity(0.8))
                            .cornerRadius(25)
                            .shadow(color: Color.customPink.opacity(0.5), radius: 10, x: 0, y: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.customPink, lineWidth: 4)
                            )
                        }
                        .padding(.horizontal, 45)
                        .padding(.bottom, 10)
                        .sheet(isPresented: $isShareSheetPresented) {
                            if let pngData = qrImage.pngData() {
                                ShareSheet(activityItems: [pngData])
                            }
                        }
                    }

                    Button(action: {
                        if isPresentedFromGroupMembers {
                            dismiss()
                        } else {
                            navigateToCustomTab = true
                        }
                    }) {
                        HStack {
                            Image(systemName: isPresentedFromGroupMembers ? "xmark.circle.fill" : "checkmark.square.fill")
                                .foregroundStyle(Color.customPink)
                            Text(isPresentedFromGroupMembers ? "閉じる" : "次へ")
                                .font(.headline)
                                .foregroundColor(.customPink)
                                .fontWeight(.bold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.customWhite.opacity(0.8))
                        .cornerRadius(25)
                        .shadow(color: Color.customPink.opacity(0.5), radius: 10, x: 0, y: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.customPink, lineWidth: 4)
                        )
                    }
                    .padding(.horizontal, 45)
                    .padding(.bottom, 40)

                } else {
                    Text("ユーザーIDを取得できませんでした")
                        .font(.body)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            .onAppear {
                viewModel.generateGroupAndQRCode(currentUID: authViewModel.currentUID)
            }
            .padding()
            .edgesIgnoringSafeArea(.bottom)
        }
        .ignoresSafeArea()
    }
}
