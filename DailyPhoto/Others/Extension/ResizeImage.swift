//
//  ResizeImage.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/24.
//
import SwiftUI

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    let widthRatio = targetSize.width / size.width
    let heightRatio = targetSize.height / size.height
    let scaleFactor = min(widthRatio, heightRatio)

    let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
    let format = UIGraphicsImageRendererFormat()
    format.scale = 1

    return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
        image.draw(in: CGRect(origin: .zero, size: newSize))
    }
}

extension UIImage {
    func croppedToAspectRatio(_ aspectWidth: CGFloat, _ aspectHeight: CGFloat) -> UIImage? {
        let originalWidth = self.size.width
        let originalHeight = self.size.height

        let targetWidth = originalHeight * (aspectWidth / aspectHeight)
        let targetHeight = originalWidth * (aspectHeight / aspectWidth)

        let cropWidth = min(targetWidth, originalWidth)
        let cropHeight = min(targetHeight, originalHeight)

        let cropRect = CGRect(
            x: (originalWidth - cropWidth) / 2,
            y: (originalHeight - cropHeight) / 2,
            width: cropWidth,
            height: cropHeight
        )

        guard let cgImage = self.cgImage?.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
