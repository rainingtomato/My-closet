import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("首页", systemImage: "square.grid.2x2")
            }

            NavigationStack {
                AddView()
            }
            .tabItem {
                Label("添加", systemImage: "plus.circle")
            }

            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label("统计", systemImage: "chart.bar")
            }
        }
    }
}
