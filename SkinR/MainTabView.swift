// MainTabView.swift
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: CaptureStore
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        TabView {
            CaptureView(store: store, settings: settings)
                .tabItem { Label("Capture", systemImage: "camera") }

            ProgressScreen(store: store, settings: settings)
                .tabItem { Label("Progress", systemImage: "chart.line.uptrend.xyaxis") }

            IngredientsView(store: store, settings: settings)
                .tabItem { Label("Ingredients", systemImage: "leaf.circle") }
        }
        .accentColor(.skinrTeal)
    }
}
