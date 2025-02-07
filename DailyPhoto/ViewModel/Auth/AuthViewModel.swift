//
//  AuthViewModel.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/02.
//

import Foundation
import FirebaseAuth
import PhotosUI
import _PhotosUI_SwiftUI

class AuthViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var iconData: Data?
    @Published var iconSelection: PhotosPickerItem?
    @Published var errorMessage: String = ""
    @Published var isSignedUp: Bool = false
    @Published var isLoggedIn: Bool = false {
        didSet {
            UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
            if isLoggedIn { shouldNavigate = true }
        }
    }
    @Published var shouldNavigate: Bool = false
    @Published var currentUID: String? = nil
    @Published var isLoading: Bool = true
    @Published var navigateToMainView: Bool = false
    @Published var navigateToQRCodeView: Bool = false
    @Published var iconURL: String? = nil
    @Published var profileIconURL: String? = nil

    init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        self.currentUID = Auth.auth().currentUser?.uid
    }

    func signUp() {
        Task {
            do {
                let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
                let uid = authResult.user.uid
                var uploadedIconURL: String? = nil
                if let iconData = iconData {
                    uploadedIconURL = try await FirebaseClient.uploadUserIcon(data: iconData, uid: uid)
                }

                let profileData = ProfileModel(id: uid, name: name, iconURL: uploadedIconURL, createdAt: Date())
                try await FirebaseClient.settingProfile(data: profileData, uid: uid)

                DispatchQueue.main.async {
                    self.isSignedUp = true
                    self.isLoggedIn = true
                    self.currentUID = uid
                    self.iconURL = uploadedIconURL
                }

                await login()
                await fetchUserProfile()

            } catch {
                DispatchQueue.main.async {
                    self.isSignedUp = false
                    self.isLoggedIn = false
                    self.errorMessage = "アカウント作成エラー: \(error.localizedDescription)"
                }
            }
        }
    }

    func login() {
        Task { [weak self] in
            do {
                let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
                self?.currentUID = authResult.user.uid

                DispatchQueue.main.async {
                    self?.isLoggedIn = true
                    self?.errorMessage = ""

                    self?.checkUserStatus()
                }
            } catch {
                DispatchQueue.main.async {
                    self?.isLoggedIn = false
                    self?.errorMessage = "ログインエラー: \(error.localizedDescription)"
                }
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.currentUID = nil
                self.isLoggedIn = false
                self.errorMessage = ""
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "ログアウトエラー: \(error.localizedDescription)"
            }
        }
    }
    func deleteAccount(password: String) {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            self.errorMessage = "ユーザー情報を取得できませんでした。"
            return
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                try await user.reauthenticate(with: credential)
                print("✅ 再認証成功")

                
                try await user.delete()

                DispatchQueue.main.async {
                    self.isLoggedIn = false
                    self.currentUID = nil
                }
                logout()

                print("🎉 アカウント削除成功")
            } catch let error as NSError {
                DispatchQueue.main.async {
                    switch error.code {
                    case AuthErrorCode.wrongPassword.rawValue:
                        self.errorMessage = "パスワードが間違っています。"
                    case AuthErrorCode.userNotFound.rawValue:
                        self.errorMessage = "ユーザーが見つかりません。"
                    case AuthErrorCode.networkError.rawValue:
                        self.errorMessage = "ネットワークエラーが発生しました。"
                    default:
                        self.errorMessage = "アカウント削除エラー: \(error.localizedDescription)"
                    }
                }
                print("⚠️ アカウント削除エラー: \(error.localizedDescription)")
            }
        }
    }
    
    func resetPassword() {
        Task { [weak self] in
            do {
                try await Auth.auth().sendPasswordReset(withEmail: email)

                DispatchQueue.main.async {
                    self?.errorMessage = "パスワードリセットメールを送信しました。"
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "パスワードリセットエラー: \(error.localizedDescription)"
                }
            }
        }
    }

    func checkUserStatus() {
        Task {
            DispatchQueue.main.async {
                self.isLoading = true
            }

            guard self.isLoggedIn, let uid = self.currentUID else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }

            do {
                let isMember = try await FirebaseClient.isUserInAnyGroup(userId: uid)
                DispatchQueue.main.async {
                    self.isLoading = false
                    if isMember {
                        self.navigateToMainView = true
                    } else {
                        self.navigateToQRCodeView = true
                    }
                }
            } catch {
                print("エラー: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    func fetchUserProfile() {
        Task { [weak self] in
            guard let self = self, let uid = self.currentUID else {
                return
            }

            do {
                let profile = try await FirebaseClient.getProfileData(uid: uid)
                DispatchQueue.main.async {
                    self.name = profile.name
                    self.iconURL = profile.iconURL
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "プロフィール取得エラー: \(error.localizedDescription)"
                }
            }
        }
    }
    func updateProfile(newName: String?, newIconData: Data?) {
        Task { [weak self] in
            guard let self = self, let uid = self.currentUID else { return }

            do {
                try await FirebaseClient.updateUserProfile(uid: uid, name: newName, iconData: newIconData)

                await self.fetchUserProfile()
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "プロフィール更新エラー: \(error.localizedDescription)"
                }
            }
        }
    }
    func getIconURL() -> String? {
        if let iconURL = Auth.auth().currentUser?.photoURL?.absoluteString {
            return iconURL
        }
        return nil
    }
    func fetchProfile() {
        Task {
            do {
                guard let uid = Auth.auth().currentUser?.uid else {
                    DispatchQueue.main.async {
                        self.profileIconURL = nil
                    }
                    return
                }
                let profile = try await FirebaseClient.getProfileData(uid: uid)

                DispatchQueue.main.async {
                    self.name = profile.name
                    self.profileIconURL = profile.iconURL
                }
            } catch {
                DispatchQueue.main.async {
                    self.profileIconURL = nil
                }
            }
        }
    }
}
