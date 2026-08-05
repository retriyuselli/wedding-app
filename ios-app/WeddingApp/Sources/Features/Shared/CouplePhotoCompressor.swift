import Combine
import UIKit

/// In-memory couple photo so Beranda / Pasangan can show the image immediately after pick/upload,
/// even before (or if) the remote URL fetch succeeds.
@MainActor
final class CouplePhotoStore: ObservableObject {
    static let shared = CouplePhotoStore()

    @Published private(set) var previewImage: UIImage?
    /// JPEG payload kept across navigation so an unsaved pick is not lost when leaving Pasangan.
    private(set) var pendingUploadData: Data?

    func setPreview(_ image: UIImage?, uploadData: Data? = nil) {
        previewImage = image
        if let uploadData {
            pendingUploadData = uploadData
        }
    }

    func clearPendingUpload() {
        pendingUploadData = nil
    }

    func clear() {
        previewImage = nil
        pendingUploadData = nil
    }
}

/// Compresses couple photos under the API/PHP upload limit (~2 MB).
enum CouplePhotoCompressor {
    /// Target payload size after multipart overhead.
    static let maxUploadBytes = 1_850_000

    /// Returns JPEG data at or below `maxBytes`, shrinking dimensions as needed.
    /// Large originals are converted automatically so callers do not need a size warning.
    static func jpegData(from image: UIImage, maxBytes: Int = maxUploadBytes) -> Data? {
        var maxDimension: CGFloat = 1600
        var working = resized(image, maxDimension: maxDimension) ?? image

        for _ in 0..<10 {
            if let data = jpegUnderLimit(working, maxBytes: maxBytes) {
                return data
            }

            maxDimension *= 0.72
            if maxDimension < 420 {
                break
            }
            working = resized(image, maxDimension: maxDimension) ?? working
        }

        let fallback = resized(image, maxDimension: 420) ?? working
        return jpegUnderLimit(fallback, maxBytes: maxBytes, minimumQuality: 0.15)
            ?? fallback.jpegData(compressionQuality: 0.12)
    }

    private static func jpegUnderLimit(
        _ image: UIImage,
        maxBytes: Int,
        minimumQuality: CGFloat = 0.25
    ) -> Data? {
        var quality: CGFloat = 0.88

        while quality >= minimumQuality {
            guard let data = image.jpegData(compressionQuality: quality) else {
                quality -= 0.08
                continue
            }
            if data.count <= maxBytes {
                return data
            }
            quality -= 0.08
        }

        return nil
    }

    private static func resized(_ image: UIImage, maxDimension: CGFloat) -> UIImage? {
        let size = image.size
        guard size.width > 0, size.height > 0 else { return nil }

        let longest = max(size.width, size.height)
        guard longest > maxDimension else { return image }

        let scale = maxDimension / longest
        let newSize = CGSize(
            width: (size.width * scale).rounded(.down),
            height: (size.height * scale).rounded(.down)
        )
        guard newSize.width >= 1, newSize.height >= 1 else { return nil }

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
