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
    @Binding var navigateToCustomTab: Bool
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var generatedGroupId: String?
    @State private var groupMembers: [String] = []
    let groupName = "My Group"

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

                    if let qrCodeContent = generatedGroupId {
                        if let qrImage = generateQRCode(from: qrCodeContent) {
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
                        } else {
                            Text("QRコードの生成に失敗しました")
                                .foregroundColor(.red)
                        }
                    }
                    Spacer()


                    Button(action: {
                        navigateToCustomTab = true
                    }) {
                        HStack {
                            Image(systemName: "checkmark.square.fill")
                                .foregroundStyle(Color.customPink)
                            Text("次へ")
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
                generateGroupAndQRCode()
            }
            .padding()
            .edgesIgnoringSafeArea(.bottom)
        }
        .ignoresSafeArea()
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        guard let outputImage = filter.outputImage else { return nil }

        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setValue(outputImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(color: .customPink), forKey: "inputColor0")
        colorFilter.setValue(CIColor(color: .clear), forKey: "inputColor1")

        guard let coloredImage = colorFilter.outputImage else { return nil }

        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = coloredImage.transformed(by: transform)

        let context = CIContext()
        if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }

    private func generateGroupAndQRCode() {
        guard let currentUID = authViewModel.currentUID else {
            errorMessage = "ユーザーIDが取得できませんでした"
            return
        }

        Task {
            do {
                isSaving = true
                errorMessage = nil
                successMessage = nil

                let groupId = UUID().uuidString
                generatedGroupId = groupId

                let group = GroupModel(id: groupId, name: groupName, createdAt: Date(), members: [currentUID])
                try await FirebaseClient.createGroup(group: group)

                successMessage = "グループが作成され、QRコードが生成されました: \(groupId)"
                fetchGroupMembers(groupId: groupId)
                isSaving = false
            } catch {
                errorMessage = "グループの作成に失敗しました: \(error.localizedDescription)"
                isSaving = false
            }
        }
    }

    private func fetchGroupMembers(groupId: String) {
        Task {
            do {
                let group = try await FirebaseClient.fetchGroup(groupId: groupId)
                groupMembers = group.members
            } catch {
                errorMessage = "参加者の取得に失敗しました: \(error.localizedDescription)"
            }
        }
    }
}
