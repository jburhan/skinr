// CalibrationView.swift
import SwiftUI

struct CalibrationView: View {
    @ObservedObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pigmentation sensitivity")) {
                    Slider(value: $settings.pigScale, in: 0.5...3.0, step: 0.1) {
                        Text("Pigmentation scale")
                    }
                    Text(String(format: "Current: %.1fx", settings.pigScale))
                }

                Section(header: Text("Redness sensitivity")) {
                    Slider(value: $settings.redScale, in: 1.0...10.0, step: 0.5) {
                        Text("Redness scale")
                    }
                    Text(String(format: "Current: %.1fx", settings.redScale))
                }

                Section(header: Text("Baseline")) {
                    if let basePig = settings.baselinePigmentation,
                       let baseRed = settings.baselineRedness {
                        Text("Baseline pigmentation: \(basePig)")
                        Text("Baseline redness: \(baseRed)")

                        Button(role: .destructive) {
                            settings.baselinePigmentation = nil
                            settings.baselineRedness = nil
                        } label: {
                            Text("Reset baseline")
                        }
                    } else {
                        Text("Baseline will be set on the next successful capture.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Calibration")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

