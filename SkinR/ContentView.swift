// ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject private var store = CaptureStore()
    @StateObject private var settings = SettingsStore()

    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
            } else {
                TabView {
                    CaptureView(store: store, settings: settings)
                        .tabItem {
                            Label("Capture", systemImage: "camera")
                        }

                    ProgressScreen(store: store, settings: settings)
                        .tabItem {
                            Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                        }

                    IngredientsView(store: store, settings: settings)
                        .tabItem {
                            Label("Ingredients", systemImage: "leaf.circle")
                        }
                    
                    SettingsView(store: store, settings: settings)
                        .tabItem {
                            Label("Settings", systemImage: "gearshape")
                        }
                }
                .accentColor(.skinrTeal)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}
