// Makes picked photos smaller before saving so the app's storage stays small

import UIKit
import PhotosUI
import SwiftUI

enum PhotoShrinker {
    // Load the photo someone picked and shrink it, or nil if it couldn't be read
    static func load(_ item: PhotosPickerItem) async -> Data? {
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                return smallerJPEG(from: data)
            }
        } catch {
            print("Couldn't load photo: \(error)")
        }
        return nil
    }

    // Resize so the longest side is at most 1200 points, then save as JPEG
    static func smallerJPEG(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else {
            return nil
        }

        let longestSide = max(image.size.width, image.size.height)
        let maxSide: CGFloat = 1200
        if longestSide <= maxSide {
            return image.jpegData(compressionQuality: 0.8)
        }

        let scale = maxSide / longestSide
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        // Scale 1 so the size is real pixels, not 3× for the screen
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let smallerImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return smallerImage.jpegData(compressionQuality: 0.8)
    }
}
