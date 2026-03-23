import Foundation
import SwiftData
import SwiftUI

struct HomeView: View {
    @Query(
        filter: #Predicate<ClothingItem> { !$0.isArchived },
        sort: [SortDescriptor(\ClothingItem.addDate, order: .reverse)]
    )
    private var activeItems: [ClothingItem]

    @Query private var categorySettings: [CategorySettings]

    private let gridColumns = [GridItem(.adaptive(minimum: 120), spacing: 12)]

    private var categoryTree: [String: [String]] {
        categorySettings.first?.categoryTree ?? CategoryDefaults.tree
    }

    private var mainCategories: [String] {
        categoryTree.keys.sorted()
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(mainCategories, id: \.self) { mainCategory in
                    NavigationLink {
                        CategoryDetailView(mainCategory: mainCategory)
                    } label: {
                        CategoryFolderCard(
                            mainCategory: mainCategory,
                            itemCount: activeItems.filter { $0.mainCategory == mainCategory }.count
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("我的衣橱")
    }
}

private struct CategoryFolderCard: View {
    let mainCategory: String
    let itemCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Image(systemName: "folder.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                Spacer()
                Text("\(itemCount)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            Text(mainCategory)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(1)

            Text("有效衣物")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 98, alignment: .leading)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }
}

struct CategoryDetailView: View {
    let mainCategory: String

    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<ClothingItem> { !$0.isArchived },
        sort: [SortDescriptor(\ClothingItem.addDate, order: .reverse)]
    )
    private var activeItems: [ClothingItem]

    @Query private var categorySettings: [CategorySettings]
    @State private var selectedSubCategory: String = "全部"

    private var subCategories: [String] {
        let tree = categorySettings.first?.categoryTree ?? CategoryDefaults.tree
        return tree[mainCategory] ?? []
    }

    private var filteredItems: [ClothingItem] {
        activeItems.filter { item in
            guard item.mainCategory == mainCategory else { return false }
            if selectedSubCategory == "全部" { return true }
            return item.subCategory == selectedSubCategory
        }
    }

    private let imageColumns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    filterChip(title: "全部")
                    ForEach(subCategories, id: \.self) { sub in
                        filterChip(title: sub)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }

            ScrollView {
                LazyVGrid(columns: imageColumns, spacing: 8) {
                    ForEach(filteredItems, id: \.id) { item in
                        clothingCell(for: item)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(mainCategory)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func clothingCell(for item: ClothingItem) -> some View {
        VStack(spacing: 6) {
            StoredClothingImageView(relativePath: item.imagePath)
                .frame(height: 100)

            HStack(spacing: 4) {
                Text(item.subCategory)
                    .font(.caption2)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Text("¥" + String(format: "%.0f", item.price))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(6)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .contextMenu {
            Button(role: .destructive) {
                item.isArchived = true
                try? modelContext.save()
            } label: {
                Label("归档 / 断舍离", systemImage: "archivebox")
            }
        }
    }

    private func filterChip(title: String) -> some View {
        Button {
            selectedSubCategory = title
        } label: {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(selectedSubCategory == title ? Color.accentColor.opacity(0.15) : Color(.systemBackground))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
