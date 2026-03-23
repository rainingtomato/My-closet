import Foundation
import SwiftData

@Model
final class ClothingItem {
    @Attribute(.unique) var id: UUID
    var imagePath: String
    var mainCategory: String
    var subCategory: String
    var color: String
    var price: Double
    var addDate: Date
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        imagePath: String,
        mainCategory: String,
        subCategory: String,
        color: String,
        price: Double,
        addDate: Date = .now,
        isArchived: Bool = false
    ) {
        self.id = id
        self.imagePath = imagePath
        self.mainCategory = mainCategory
        self.subCategory = subCategory
        self.color = color
        self.price = price
        self.addDate = addDate
        self.isArchived = isArchived
    }
}
