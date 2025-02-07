//
//  CameraView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/03.
//

import SwiftUI
import AVFoundation

struct Camera: UIViewControllerRepresentable {
    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        var parent: Camera

        init(parent: Camera) {
            self.parent = parent
        }

        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            guard let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data) else { return }

            var finalImage = image

            if self.parent.isUsingFrontCamera {
                finalImage = flipImageHorizontally(image: image)
            }

            DispatchQueue.main.async {
                self.parent.capturedImage = finalImage
                self.parent.showPreview = false
            }
        }

        func flipImageHorizontally(image: UIImage) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            let context = UIGraphicsGetCurrentContext()
            context?.translateBy(x: image.size.width, y: 0)
            context?.scaleBy(x: -1.0, y: 1.0)
            image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return flippedImage ?? image
        }
    }

    @Binding var takePhoto: Bool
    @Binding var capturedImage: UIImage?
    @Binding var showPreview: Bool
    @Binding var flashEnabled: Bool
    @Binding var isUsingFrontCamera: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraViewController = CameraViewController()
        cameraViewController.coordinator = context.coordinator
        cameraViewController.flashEnabled = flashEnabled
        cameraViewController.isUsingFrontCamera = isUsingFrontCamera
        return cameraViewController
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        uiViewController.flashEnabled = flashEnabled
        if takePhoto {
            uiViewController.capturePhoto()
            DispatchQueue.main.async {
                takePhoto = false
            }
        }
        if uiViewController.isUsingFrontCamera != isUsingFrontCamera {
            uiViewController.switchCamera()
        }
    }
}
