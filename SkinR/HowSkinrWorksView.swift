// HowSkinrWorksView.swift
import SwiftUI

struct HowSkinrWorksView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("How SkinR works")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Pipeline")
                    .font(.headline)

                Text("""
                1. The SkinR mirror (Raspberry Pi + camera + ring light) captures a standardized photo of your face.
                2. The Pi sends the image over Wi-Fi to the iOS app via HTTP.
                3. The app runs a custom image analysis pipeline that computes two metrics:
                   • Pigmentation (evenness of tone)
                   • Redness (visible erythema / inflammation proxy)
                4. Scores are stored on your device and visualized over time in the Progress and Ingredients tabs.
                """)
                .font(.footnote)
                .foregroundColor(.secondary)

                Text("What the scores mean")
                    .font(.headline)

                Text("""
                • Pigmentation score (0–100) estimates how uneven your skin tone is in the captured image. Higher scores indicate more contrast and localized darkening.
                • Redness score (0–100) estimates visible redness in the captured image based on color channels. Higher scores indicate more red signal.
                • Baseline is set from your first capture and used as a personal reference instead of comparing you to other people.
                """)
                .font(.footnote)
                .foregroundColor(.secondary)

                Text("Limitations")
                    .font(.headline)

                Text("""
                • Scores are sensitive to lighting, camera angle, and how much of your face is visible.
                • SkinR does not diagnose conditions like rosacea, eczema, or melasma.
                • The metrics are experimental and should be used as a cosmetic signal only, not as medical advice.
                """)
                .font(.footnote)
                .foregroundColor(.secondary)

                Text("Best practices for consistent scans")
                    .font(.headline)

                Text("""
                • Use the mirror in the same room and distance each time.
                • Keep the ring light on and avoid strong side lighting.
                • Keep your face centered and relaxed.
                • Track trends over weeks, not single readings.
                """)
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("How SkinR works")
        .navigationBarTitleDisplayMode(.inline)
    }
}
