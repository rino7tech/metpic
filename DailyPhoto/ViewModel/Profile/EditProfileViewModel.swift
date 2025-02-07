//
//  EditProfileViewModel.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/24.
//

import SwiftUI
import PhotosUI
import Kingfisher

class EditProfileViewModel: ObservableObject {
    @Published var newName: String
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var selectedUIImage: UIImage? = nil
    @Published var editProfile: Bool = false
    @Published var imageUrl: String
    @Published var isLoading: Bool = false

    private var authViewModel: AuthViewModel

    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        self.newName = authViewModel.name
        self.imageUrl = authViewModel.profileIconURL ?? ""
    }

    func selectPhoto(newValue: PhotosPickerItem?) {
        Task {
            isLoading = true
            defer { isLoading = false }

            if let newValue = newValue {
                do {
                    if let data = try await newValue.loadTransferable(type: Data.self) {
                        selectedUIImage = UIImage(data: data)
                        authViewModel.iconData = data
                    }
                } catch {
                    print("画像の取得に失敗: \(error.localizedDescription)")
                }
            }
        }
    }

    func saveProfile() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                async let updateTask = FirebaseClient.updateUserProfile(
                    uid: authViewModel.currentUID,
                    name: newName.isEmpty ? nil : newName,
                    iconData: authViewModel.iconData
                )

                async let fetchProfileTask = authViewModel.fetchProfile()

                try await (updateTask, fetchProfileTask)
                editProfile = false
                print("プロフィール更新成功")
            } catch {
                print("プロフィール更新エラー: \(error.localizedDescription)")
            }
        }
    }

    func logout() {
        authViewModel.logout()
    }
    
    func deleteAccount(password: String) {
        authViewModel.deleteAccount(password: password)
    }
    
    
    func fetchProfile() {
        Task {
            isLoading = true
            defer { isLoading = false }
            await authViewModel.fetchProfile()
        }
    }
}
