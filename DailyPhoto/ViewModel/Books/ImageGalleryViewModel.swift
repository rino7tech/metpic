//
//  ImageGalleryViewModel.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/25.
//


import Foundation
import Firebase

class ImageGalleryViewModel: ObservableObject {
    @Published var images: [ImageModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchImages(uid: String, sectionId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedImages = try await FirebaseClient.fetchImagesForSection(uid: uid, sectionId: sectionId)
            DispatchQueue.main.async {
                self.images = fetchedImages
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to fetch images: \(error.localizedDescription)"
            }
        }

        isLoading = false
    }

    func dismiss() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("CloseGalleryView"), object: nil)
        }
    }
}