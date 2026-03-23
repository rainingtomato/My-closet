import Foundation
import SwiftData
import SwiftUI

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor(\ClothingItem.addDate, order: .reverse)])
    private var allItems: [ClothingItem]

    private var activeItems: [ClothingItem] {
        allItems.filter { !$0.isArchived }
    }

    private var archivedItems: [ClothingItem] {
        allItems.filter(\.isArchived)
    }

    private var activeCount: Int { activeItems.count }
    private var activeTotalValue: Double { activeItems.reduce(0) { $0 + $1.price } }
    private var archivedCount: Int { archivedItems.count }
    private var archivedSunkCost: Double { archivedItems.reduce(0) { $0 + $1.price } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("数据仪表盘")
                    .font(.title3.bold())
                    .padding(.top, 4)

                StatCard(
                    title: "有效衣物总件数",
                    valueText: "\(activeCount) 件",
                    icon: "tshirt"
                )
                StatCard(
                    title: "有效衣物总价值",
                    valueText: "¥" + String(format: "%.2f", activeTotalValue),
                    icon: "yensign.circle"
                )

                Text("归档区（断舍离）")
                    .font(.title3.bold())
                    .padding(.top, 6)

                StatCard(
                    title: "已归档总件数",
                    valueText: "\(archivedCount) 件",
                    icon: "archivebox"
                )
                StatCard(
                    title: "沉没成本总计",
                    valueText: "¥" + String(format: "%.2f", archivedSunkCost),
                    icon: "exclamationmark.triangle"
                )

                if archivedItems.isEmpty {
                    Text("暂无归档衣物")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("已归档列表")
                            .font(.headline)
                        ForEach(archivedItems.prefix(12), id: \.id) { item in
                            archivedRow(item)
                        }
                    }
                    .padding(.top, 6)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("数据统计")
    }

    private func archivedRow(_ item: ClothingItem) -> some View {
        HStack(spacing: 10) {
            StoredClothingImageView(relativePath: item.imagePath)
                .frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(item.mainCategory) · \(item.subCategory)")
                    .font(.subheadline)
                Text("¥" + String(format: "%.2f", item.price))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("恢复") {
                item.isArchived = false
                try? modelContext.save()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.vertical, 4)
    }
}

private struct StatCard: View {
    let title: String
    let valueText: String
    let icon: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 28)
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(valueText)
                    .font(.title3.bold())
            }
            Spacer()
        }
        .padding(14)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
