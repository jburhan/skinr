// SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: CaptureStore
    @ObservedObject var settings: SettingsStore

    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Data & privacy")) {
                    Label(
                        title: {
                            Text("Photos stay on this device")
                        },
                        icon: {
                            Image(systemName: "lock.shield")
                        }
                    )
                    .font(.subheadline)

                    Text("Skinr saves your captures and scores locally on your iPhone. Nothing is uploaded to external servers.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Section(header: Text("Baseline & calibration")) {
                    if let basePig = settings.baselinePigmentation,
                       let baseRed = settings.baselineRedness {
                        Text("Baseline pigmentation: \(basePig)")
                        Text("Baseline redness: \(baseRed)")
                    } else {
                        Text("Baseline will be set on your next successful capture.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                    NavigationLink("Open calibration") {
                        CalibrationView(settings: settings)
                    }
                }

                Section(header: Text("How SkinR works")) {
                    NavigationLink {
                        HowSkinrWorksView()
                    } label: {
                        Label("See pipeline & limitations", systemImage: "info.circle")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete all data", systemImage: "trash")
                    }
                } footer: {
                    Text("Removes all captures, scores, and baseline values from this device.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .alert("Delete all data?",
                   isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    store.deleteAllCaptures()
                    settings.resetAll()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently remove all captured images and stored scores from this device.")
            }
        }
    }
}
