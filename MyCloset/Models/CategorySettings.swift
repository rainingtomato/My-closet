import Foundation
import SwiftData

@Model
final class CategorySettings {
    @Attribute(.unique) var id: UUID
    var categoryTreeData: Data

    init(
        id: UUID = UUID(),
        categoryTree: [String: [String]] = CategoryDefaults.tree
    ) {
        self.id = id
        self.categoryTreeData = Self.encode(categoryTree)
    }

    var categoryTree: [String: [String]] {
        get { Self.decode(categoryTreeData) }
        set { categoryTreeData = Self.encode(newValue) }
    }
}

private extension CategorySettings {
    static func encode(_ tree: [String: [String]]) -> Data {
        (try? JSONEncoder().encode(tree)) ?? Data()
    }

    static func decode(_ data: Data) -> [String: [String]] {
        guard let tree = try? JSONDecoder().decode([String: [String]].self, from: data), !tree.isEmpty else {
            return CategoryDefaults.tree
        }
        return tree
    }
}

enum CategoryDefaults {
    static let tree: [String: [String]] = [
        "上衣": ["T恤", "衬衫", "卫衣", "毛衣", "外套", "西装"],
        "下装": ["牛仔裤", "休闲裤", "短裤", "半身裙", "西裤"],
        "连体": ["连衣裙", "连体裤", "套装"],
        "鞋靴": ["运动鞋", "皮鞋", "凉鞋", "短靴", "高跟鞋"],
        "配饰": ["包袋", "帽子", "腰带", "围巾", "首饰"]
    ]
}

enum ColorPalette {
    // 20 个基础颜色标签（用于标准化存储）
    static let twentyColors: [String] = [
        "白", "黑", "灰", "银", "米", "卡其", "棕", "咖",
        "红", "酒红", "橙", "黄", "姜黄", "绿", "墨绿", "蓝",
        "藏蓝", "青", "紫", "粉"
    ]

    // AddView 中的 8 个快速单选色
    static let quickPickColors: [String] = [
        "白", "黑", "灰", "蓝", "红", "绿", "棕", "米"
    ]
}
