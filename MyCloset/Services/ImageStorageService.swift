import Foundation
import UIKit

enum ImageStorageError: LocalizedError {
    case invalidJPEGData
    case unableToCreateDirectory

    var errorDescription: String? {
        switch self {
        case .invalidJPEGData:
            return "图片编码失败，无法保存。"
        case .unableToCreateDirectory:
            return "无法创建图片存储目录。"
        }
    }
}

struct ImageStorageService {
    private static let folderName = "ClosetImages"

    static func saveProcessedImage(_ image: UIImage) throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.95) else {
            throw ImageStorageError.invalidJPEGData
        }

        let fm = FileManager.default
        let baseURL = try imagesDirectoryURL(fileManager: fm)
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = baseURL.appendingPathComponent(fileName)
        try data.write(to: fileURL, options: .atomic)
        return "\(folderName)/\(fileName)"
    }

    static func loadImage(relativePath: String) -> UIImage? {
        let url = documentsURL().appendingPathComponent(relativePath)
        return UIImage(contentsOfFile: url.path)
    }
}

private extension ImageStorageService {
    static func imagesDirectoryURL(fileManager: FileManager) throws -> URL {
        let directory = documentsURL().appendingPathComponent(folderName, isDirectory: true)
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory)

        if exists {
            if isDirectory.boolValue { return directory }
            throw ImageStorageError.unableToCreateDirectory
        }

        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    static func documentsURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
