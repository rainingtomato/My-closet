import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import Vision

enum VisionBackgroundProcessorError: LocalizedError {
    case unsupportedSystem
    case ciImageCreationFailed
    case missingMaskResult
    case renderedImageCreationFailed

    var errorDescription: String? {
        switch self {
        case .unsupportedSystem:
            return "当前系统版本不支持自动抠图（需要 iOS 17+）。"
        case .ciImageCreationFailed:
            return "图片读取失败，无法开始抠图。"
        case .missingMaskResult:
            return "未检测到可抠图主体，请更换更清晰的图片。"
        case .renderedImageCreationFailed:
            return "抠图处理失败，请重试。"
        }
    }
}

final class VisionBackgroundProcessor {
    private let ciContext = CIContext()

    func makeWhiteBackgroundImage(from uiImage: UIImage) throws -> UIImage {
        guard #available(iOS 17.0, *) else {
            throw VisionBackgroundProcessorError.unsupportedSystem
        }

        guard let inputCIImage = Self.normalizedCIImage(from: uiImage) else {
            throw VisionBackgroundProcessorError.ciImageCreationFailed
        }

        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(ciImage: inputCIImage)
        try handler.perform([request])

        guard let observation = request.results?.first else {
            throw VisionBackgroundProcessorError.missingMaskResult
        }

        let maskBuffer = try observation.generateScaledMaskForImage(
            forInstances: observation.allInstances,
            from: handler
        )
        let maskImage = CIImage(cvPixelBuffer: maskBuffer)
        let whiteBackground = CIImage(color: CIColor(red: 1, green: 1, blue: 1)).cropped(to: inputCIImage.extent)

        let blendFilter = CIFilter.blendWithMask()
        blendFilter.inputImage = inputCIImage
        blendFilter.backgroundImage = whiteBackground
        blendFilter.maskImage = maskImage

        guard
            let output = blendFilter.outputImage,
            let cgImage = ciContext.createCGImage(output, from: output.extent)
        else {
            throw VisionBackgroundProcessorError.renderedImageCreationFailed
        }

        return UIImage(cgImage: cgImage)
    }
}

private extension VisionBackgroundProcessor {
    static func normalizedCIImage(from image: UIImage) -> CIImage? {
        if let ciImage = image.ciImage {
            return ciImage.oriented(forExifOrientation: Int32(image.imageOrientation.exifOrientation))
        }
        guard let cgImage = image.cgImage else { return nil }
        return CIImage(cgImage: cgImage).oriented(forExifOrientation: Int32(image.imageOrientation.exifOrientation))
    }
}

private extension UIImage.Orientation {
    var exifOrientation: UInt32 {
        switch self {
        case .up: return 1
        case .upMirrored: return 2
        case .down: return 3
        case .downMirrored: return 4
        case .leftMirrored: return 5
        case .right: return 6
        case .rightMirrored: return 7
        case .left: return 8
        @unknown default: return 1
        }
    }
}
