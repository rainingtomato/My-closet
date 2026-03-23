import SwiftData
import SwiftUI

@main
struct MyClosetApp: App {
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: ClothingItem.self, CategorySettings.self)
            seedDefaultCategorySettingsIfNeeded(using: modelContainer)
        } catch {
            fatalError("ModelContainer 初始化失败: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(modelContainer)
    }
}

private extension MyClosetApp {
    func seedDefaultCategorySettingsIfNeeded(using container: ModelContainer) {
        let context = ModelContext(container)
        var descriptor = FetchDescriptor<CategorySettings>()
        descriptor.fetchLimit = 1

        if (try? context.fetch(descriptor).first) == nil {
            context.insert(CategorySettings())
            try? context.save()
        }
    }
}
