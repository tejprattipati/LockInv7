import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem { Label("Today", systemImage: "house.fill") }.tag(0)
            InterveneView()
                .tabItem { Label("Intervene", systemImage: "bolt.shield.fill") }.tag(1)
            PlanEditorView()
                .tabItem { Label("Plan", systemImage: "list.clipboard.fill") }.tag(2)
            CutProgressView()
                .tabItem { Label("Progress", systemImage: "chart.line.uptrend.xyaxis") }.tag(3)
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }.tag(4)
        }
        .tint(LockInTheme.accent)
        .onAppear { seedIfNeeded() }
    }

    private func seedIfNeeded() {
        DataSeeder.seedIfNeeded(context: modelContext)
    }
}
