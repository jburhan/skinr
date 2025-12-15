// CaptureView.swift

import SwiftUI
import UIKit

struct CaptureView: View {
    @ObservedObject var store: CaptureStore
    @ObservedObject var settings: SettingsStore
    
    @State private var piBaseURL: String = "http://192.168.1.10:5000"
    @State private var isCapturing: Bool = false
    @State private var errorMessage: String?
    @State private var capturedImage: UIImage?

    @State private var pigmentationScore: Int?
    @State private var rednessScore: Int?

    @State private var showingCalibration: Bool = false

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Brand header
                SkinrBrandHeader()

                // Capture button
                Button(action: captureImage) {
                    HStack {
                        if isCapturing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "camera.fill")
                            Text("Capture")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .disabled(isCapturing || piBaseURL.isEmpty)
                .background(
                    (isCapturing || piBaseURL.isEmpty)
                    ? Color.gray.opacity(0.4)
                    : Color.skinrTeal
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.top, 4)

                // Error message
                if let msg = errorMessage {
                    Text(msg)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Latest scores + baseline deltas
                if let pig = pigmentationScore, let red = rednessScore {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current picture scores")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        VStack(alignment: .leading, spacing: 4) {
                            if let basePig = settings.baselinePigmentation {
                                let delta = pig - basePig
                                Text("Pigmentation: \(pig)/100 (\(delta >= 0 ? "+" : "")\(delta) vs baseline)")
                            } else {
                                Text("Pigmentation: \(pig)/100")
                            }

                            if let baseRed = settings.baselineRedness {
                                let delta = red - baseRed
                                Text("Redness: \(red)/100 (\(delta >= 0 ? "+" : "")\(delta) vs baseline)")
                            } else {
                                Text("Redness: \(red)/100")
                            }
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                }

                // Image list
                if store.records.isEmpty {
                    Text("No image captures yet")
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    Spacer()
                } else {
                    List {
                        ForEach(store.records) { record in
                            VStack(spacing: 12) {
                                Text(dateFormatter.string(from: record.timestamp))
                                    .font(.subheadline)

                                Text("Original image")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                if let orig = store.originalImage(for: record) {
                                    HStack {
                                        Spacer()
                                        Image(uiImage: orig)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxHeight: 260)
                                            .cornerRadius(15)
                                        Spacer()
                                    }
                                }

                                Text("Analyzed image")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                if let ov = store.overlayImage(for: record) {
                                    HStack {
                                        Spacer()
                                        Image(uiImage: ov)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxHeight: 260)
                                            .cornerRadius(15)
                                        Spacer()
                                    }
                                }

                                VStack(spacing: 4) {
                                    Text("Pigmentation: \(record.pigmentationScore) • Redness: \(record.rednessScore)")
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)

                                Button(role: .destructive) {
                                    store.delete(record: record)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .tint(.red)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .listStyle(.plain)
                }

                Spacer()
            }
            .padding()
            .background(Color.skinrOffWhite.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Calibrate") {
                        showingCalibration = true
                    }
                }
            }
            .sheet(isPresented: $showingCalibration) {
                CalibrationView(settings: settings)
            }
        }
    }

    // MARK: - Capture + Analysis

    private func captureImage() {
        guard let url = URL(string: piBaseURL + "/capture") else {
            errorMessage = "Invalid Pi URL"
            return
        }

        isCapturing = true
        errorMessage = nil

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isCapturing = false

                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let httpResp = response as? HTTPURLResponse else {
                    self.errorMessage = "Invalid response"
                    return
                }

                guard (200..<300).contains(httpResp.statusCode) else {
                    self.errorMessage = "HTTP error: \(httpResp.statusCode)"
                    return
                }

                guard let data = data, let image = UIImage(data: data) else {
                    self.errorMessage = "Invalid image data"
                    return
                }

                self.handleCaptured(image: image)
            }
        }
        task.resume()
    }

    private func handleCaptured(image: UIImage) {
        let analyzer = SkinAnalyzer()

        if let result = analyzer.analyze(
            image: image,
            pigScale: settings.pigScale,
            redScale: settings.redScale
        ) {
            self.capturedImage = result.overlayImage
            self.pigmentationScore = result.pigmentationScore
            self.rednessScore = result.rednessScore

            settings.setBaselineIfNeeded(
                pig: result.pigmentationScore,
                red: result.rednessScore
            )

            store.addCapture(
                original: image,
                overlay: result.overlayImage,
                pigScore: result.pigmentationScore,
                redScore: result.rednessScore
            )
        } else {
            self.errorMessage = "Analysis failed"
        }
    }
}
