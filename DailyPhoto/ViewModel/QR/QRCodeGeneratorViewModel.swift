//
//  QRCodeGeneratorViewModel.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/02/09.
//

import SwiftUI
import FirebaseAuth

@MainActor
class QRCodeGeneratorViewModel: ObservableObject {
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var generatedGroupId: String?
    @Published var groupMembers: [String] = []

    let groupName = "My Group"
    
    func generateQRCode(from string: String) -> UIImage? {
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

    func generateGroupAndQRCode(currentUID: String?) {
        guard let currentUID = currentUID else {
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
