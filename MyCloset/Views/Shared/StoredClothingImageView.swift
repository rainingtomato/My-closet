import SwiftUI

struct StoredClothingImageView: View {
    let relativePath: String

    var body: some View {
        Group {
            if let image = ImageStorageService.loadImage(relativePath: relativePath) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Color(.systemGray5)
                    Image(systemName: "photo")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
