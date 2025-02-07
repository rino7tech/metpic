//
//  FirebaseClient.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/02.
//

import Foundation
import Firebase
import FirebaseStorage

enum FirebaseClientFirestoreError: Error {
    case roomModelNotFound
    case commentSubmissionFailed
}

enum FirebaseClient {
    static let db = Firestore.firestore()
    static let storage = Storage.storage()

    static func uploadImage(data: Data, groupId: String, sectionId: String) async throws -> String {
        let storageRef = storage.reference().child("groups/\(groupId)/sections/\(sectionId)/images/\(UUID().uuidString).jpg")
        _ = try await storageRef.putDataAsync(data, metadata: nil)
        return try await storageRef.downloadURL().absoluteString
    }

    static func uploadUserIcon(data: Data, uid: String) async throws -> String {
        let storageRef = storage.reference().child("users/\(uid)/icon.jpg")

        guard let image = UIImage(data: data) else {
            throw NSError(domain: "FirebaseClient", code: 500, userInfo: [NSLocalizedDescriptionKey: "画像の変換に失敗しました"])
        }

        let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 512, height: 512))

        guard let compressedData = resizedImage.jpegData(compressionQuality: 0.6) else {
            throw NSError(domain: "FirebaseClient", code: 500, userInfo: [NSLocalizedDescriptionKey: "画像の圧縮に失敗しました"])
        }

        _ = try await storageRef.putDataAsync(compressedData, metadata: nil)

        return try await storageRef.downloadURL().absoluteString
    }

    static func saveImage(data: ImageModel, groupId: String, sectionId: String) async throws {
        let documentRef = db.collection("groups").document(groupId).collection("sections").document(sectionId).collection("images").document()
        try await documentRef.setData(data.encoded)
    }

    static func fetchImages(for userId: String) async throws -> [ImageModel] {
        let group = try await fetchFirstGroupForUser(userId: userId)
        let groupId = group.id

        let sectionSnapshot = try await db.collection("groups").document(groupId).collection("sections").whereField("done", isEqualTo: false).limit(to: 1).getDocuments()

        guard let section = sectionSnapshot.documents.first else {
            throw NSError(domain: "FirebaseClient", code: 404, userInfo: [NSLocalizedDescriptionKey: "未完了のセクションが見つかりません。"])
        }

        let sectionId = section.documentID

        let snapshot = try await db.collection("groups").document(groupId).collection("sections").document(sectionId).collection("images").getDocuments()

        do {
            return try snapshot.documents.compactMap { document in
                try document.data(as: ImageModel.self)
            }
        } catch {
            throw NSError(domain: "FirebaseClient", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "画像データのデコードに失敗しました。エラー: \(error.localizedDescription)"
            ])
        }
    }

    static func fetchImagesGroupedBySection(for userId: String) async throws -> ([String: [ImageModel]], [String]) {
        let group = try await fetchFirstGroupForUser(userId: userId)
        let groupId = group.id

        let sectionSnapshot = try await db.collection("groups").document(groupId).collection("sections").getDocuments()

        var imagesBySection: [String: [ImageModel]] = [:]
        var lockedSections: [String] = []

        for section in sectionSnapshot.documents {
            let sectionId = section.documentID
            let done = section.data()["done"] as? Bool ?? false

            if done {
                let imagesSnapshot = try await db.collection("groups").document(groupId).collection("sections").document(sectionId).collection("images").getDocuments()

                let images = try imagesSnapshot.documents.compactMap { document in
                    try document.data(as: ImageModel.self)
                }

                if !images.isEmpty {
                    imagesBySection[sectionId] = images
                }
            } else {
                lockedSections.append(sectionId)
            }
        }

        return (imagesBySection, lockedSections)
    }

    static func saveImageToGroupSection(imageData: Data, userId: String) async throws -> String {
        let group = try await fetchFirstGroupForUser(userId: userId)
        let groupId = group.id

        let sectionSnapshot = try await db.collection("groups").document(groupId).collection("sections").whereField("done", isEqualTo: false).limit(to: 1).getDocuments()

        guard let section = sectionSnapshot.documents.first else {
            throw NSError(domain: "FirebaseClient", code: 404, userInfo: [NSLocalizedDescriptionKey: "未完了のセクションが見つかりません。"])
        }

        let sectionId = section.documentID

        let imageURL = try await uploadImage(data: imageData, groupId: groupId, sectionId: sectionId)

        let imageModel = ImageModel(url: imageURL, uploadedAt: Date(), capturedBy: userId)
        try await saveImage(data: imageModel, groupId: groupId, sectionId: sectionId)

        return "画像を保存しました！"
    }

    static func settingProfile(data: ProfileModel, uid: String) async throws {
        try await db.collection("users").document(uid).setData(data.encoded)
        print("✅ Firestore にデータ保存成功")
    }

    static func getProfileData(uid: String) async throws -> ProfileModel {
        let document = try await db.collection("users").document(uid).getDocument(source: .cache)

        if let data = document.data() {
            return try Firestore.Decoder().decode(ProfileModel.self, from: data)
        } else {
            let freshDocument = try await db.collection("users").document(uid).getDocument(source: .server)
            guard let freshData = freshDocument.data() else {
                throw NSError(domain: "FirebaseClient", code: 404, userInfo: [NSLocalizedDescriptionKey: "ユーザープロフィールが見つかりません"])
            }
            return try Firestore.Decoder().decode(ProfileModel.self, from: freshData)
        }
    }

    static func createGroup(group: GroupModel) async throws -> String {
        let groupRef = db.collection("groups").document(group.id)
        try await groupRef.setData(group.encoded)
        return group.id
    }

    static func addMemberToGroup(groupId: String, memberId: String) async throws {
        let groupRef = db.collection("groups").document(groupId)
        try await groupRef.updateData([
            "members": FieldValue.arrayUnion([memberId])
        ])
    }

    static func fetchGroup(groupId: String) async throws -> GroupModel {
        let groupRef = db.collection("groups").document(groupId)
        let document = try await groupRef.getDocument()

        guard let groupData = document.data() else {
            throw NSError(domain: "GroupFetchError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Group not found"])
        }

        return try Firestore.Decoder().decode(GroupModel.self, from: groupData)
    }

    static func isUserInAnyGroup(userId: String) async throws -> Bool {
        let db = Firestore.firestore()
        let groupsRef = db.collection("groups")
        let snapshot = try await groupsRef.whereField("members", arrayContains: userId).getDocuments()

        return !snapshot.documents.isEmpty
    }

    static func fetchFirstGroupForUser(userId: String) async throws -> GroupModel {
        let snapshot = try await db.collection("groups").whereField("members", arrayContains: userId).limit(to: 1).getDocuments()

        guard let document = snapshot.documents.first else {
            throw NSError(domain: "FirebaseClient", code: 404, userInfo: [NSLocalizedDescriptionKey: "No groups found for user."])
        }

        return try Firestore.Decoder().decode(GroupModel.self, from: document.data())
    }

    static func fetchMemberNames(for memberUIDs: [String]) async throws -> [String] {
        var names: [String] = []

        try await withThrowingTaskGroup(of: (String, String?).self) { group in
            for uid in memberUIDs {
                group.addTask {
                    let document = try await db.collection("users").document(uid).getDocument()
                    let name = document.data()?["name"] as? String
                    return (uid, name)
                }
            }

            for try await (_, name) in group {
                if let name = name {
                    names.append(name)
                } else {
                    names.append("Unknown Name")
                }
            }
        }
        return names
    }
    static func saveSelectedDate(groupId: String, sectionId: String, date: Date, coverImageUrl: String?) async throws {
        let formattedDate = Timestamp(date: date)
        let datePath = db.collection("groups").document(groupId).collection("sections").document(sectionId)

        var data: [String: Any] = [
            "date": formattedDate,
            "createdAt": Timestamp(date: Date()),
            "done": false
        ]

        if let coverImageUrl = coverImageUrl {
            data["coverImageUrl"] = coverImageUrl
        }

        try await datePath.setData(data, merge: true)

        Task {
            while true {
                let currentDate = Calendar.current.startOfDay(for: Date())
                let selectedDate = Calendar.current.startOfDay(for: date)
                if currentDate == selectedDate {
                    try await datePath.updateData(["done": true])
                    break
                }
                try await Task.sleep(nanoseconds: 24 * 60 * 60 * 1_000_000_000)
            }
        }
    }

    static func uploadCoverImage(data: Data, groupId: String, sectionId: String) async throws -> String {
        let storageRef = storage.reference().child("groups/\(groupId)/sections/\(sectionId)_cover.jpg")

        _ = try await storageRef.putDataAsync(data, metadata: nil)
        let downloadURL = try await storageRef.downloadURL().absoluteString

        let sectionRef = db.collection("groups").document(groupId).collection("sections").document(sectionId)
        try await sectionRef.setData(["coverImageUrl": downloadURL], merge: true)

        return downloadURL
    }

    static func checkDoneStatus(for userId: String) async throws -> Bool {
        let group = try await fetchFirstGroupForUser(userId: userId)
        let groupId = group.id

        let snapshot = try await db
            .collection("groups").document(groupId).collection("sections").whereField("done", isEqualTo: false).getDocuments()

        return !snapshot.documents.isEmpty
    }
    static func updateUserProfile(uid: String?, name: String?, iconData: Data?) async throws {
        guard let uid = uid else {
            throw NSError(domain: "FirebaseClient", code: 400, userInfo: [NSLocalizedDescriptionKey: "ユーザーIDが見つかりません。"])
        }

        let currentProfile = try? await getProfileData(uid: uid)
        let updatedName = name?.isEmpty == false ? name! : currentProfile?.name ?? "Unknown User"

        let iconUploadTask = Task<String?, Error> {
            if let iconData = iconData {
                return try await uploadUserIcon(data: iconData, uid: uid)
            } else {
                return currentProfile?.iconURL
            }
        }

        var updateData: [String: Any] = ["name": updatedName]

        if let updatedIconURL = try await iconUploadTask.value, !updatedIconURL.isEmpty {
            updateData["iconURL"] = updatedIconURL
        }

        async let firestoreUpdateTask = db.collection("users").document(uid).setData(updateData, merge: true)

        try await firestoreUpdateTask
    }

    static func fetchCoverImages(groupId: String) async throws -> [String: String] {
        let sectionSnapshot = try await db.collection("groups").document(groupId).collection("sections").getDocuments()

        var coverImages: [String: String] = [:]
        for section in sectionSnapshot.documents {
            let sectionId = section.documentID
            if let coverImageUrl = section.data()["coverImageUrl"] as? String {
                coverImages[sectionId] = coverImageUrl
            }
        }
        return coverImages
    }
    static func fetchImagesForSection(uid: String, sectionId: String) async throws -> [ImageModel] {
        let group = try await fetchFirstGroupForUser(userId: uid)
        let groupId = group.id

        print("📌 Fetching images for section: \(sectionId) in group: \(groupId)")

        let snapshot = try await db.collection("groups").document(groupId)
            .collection("sections").document(sectionId)
            .collection("images").getDocuments()

        print("📸 Found \(snapshot.documents.count) images in section \(sectionId)")

        do {
            let images = try snapshot.documents.compactMap { document -> ImageModel? in
                do {
                    return try document.data(as: ImageModel.self)
                } catch {
                    print("❌ Failed to decode document \(document.documentID): \(error)")
                    return nil
                }
            }
            print("✅ Successfully decoded images: \(images.count)")
            return images
        } catch {
            print("❌ Failed to fetch images: \(error.localizedDescription)")
            throw NSError(domain: "FirebaseClient", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "画像データの取得に失敗しました。エラー: \(error.localizedDescription)"
            ])
        }
    }
    static func fetchSectionDates(groupId: String) async throws -> [String: (createdAt: Date, date: Date?)] {
        let sectionSnapshot = try await db.collection("groups").document(groupId).collection("sections").getDocuments()

        var sectionDates: [String: (Date, Date?)] = [:]
        for section in sectionSnapshot.documents {
            let sectionId = section.documentID
            let data = section.data()

            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            let date = (data["date"] as? Timestamp)?.dateValue()

            sectionDates[sectionId] = (createdAt, date)

            print("✅ Section \(sectionId): createdAt = \(createdAt), date = \(String(describing: date))")
        }
        return sectionDates
    }
    static func fetchMembers(for memberUIDs: [String]) async throws -> [MemberModel] {
        var members: [MemberModel] = []

        try await withThrowingTaskGroup(of: MemberModel?.self) { group in
            for uid in memberUIDs {
                group.addTask {
                    let document = try await db.collection("users").document(uid).getDocument()
                    guard let data = document.data() else { return nil }

                    let name = data["name"] as? String ?? "Unknown Name"
                    let iconUrl = data["iconURL"] as? String
                    let joinedAt = (data["joinedAt"] as? Timestamp)?.dateValue() ?? Date()

                    return MemberModel(id: uid, name: name, iconUrl: iconUrl, joinedAt: joinedAt)
                }
            }

            for try await member in group {
                if let member = member {
                    members.append(member)
                }
            }
        }
        return members
    }
    static func blockUser(currentUserId: String, blockedUserId: String) async throws {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserId)
        let blockRef = userRef.collection("blocks").document(blockedUserId)

        try await blockRef.setData(["blockedAt": Timestamp(date: Date())])

        let groupSnapshot = try await db.collection("groups")
            .whereField("members", arrayContains: currentUserId)
            .getDocuments()

        for document in groupSnapshot.documents {
            let groupId = document.documentID

            let groupRef = db.collection("groups").document(groupId)
            try await groupRef.updateData([
                "members": FieldValue.arrayRemove([blockedUserId])
            ])
        }

        print("✅ ユーザー \(blockedUserId) をブロックし、参加しているグループから削除しました。")
    }
}
