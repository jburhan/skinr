// SplashView.swift
import SwiftUI

struct SplashView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var ringProgress: CGFloat = 0.0
    @State private var showDot = false
    @State private var showText = false

    var body: some View {
        let bg = (colorScheme == .dark) ? Color.black : Color.skinrOffWhite

        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 16) {
                AnimatedSkinrLogo(size: 96,
                                  ringProgress: ringProgress,
                                  showDot: showDot)

                if showText {
                    VStack(spacing: 6) {
                        Text("SkinR")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .foregroundColor(.skinrCharcoal)

                        Text("Beauty is science.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack(spacing: 6) {
                            Text("Developed in Switzerland 🇨🇭")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 2)
                    }
                    .transition(.opacity)
                }
            }
        }
        .onAppear {
            // Animate ring
            withAnimation(.easeOut(duration: 0.8)) {
                ringProgress = 1.0
            }
            // Show dot slightly after
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.4)) {
                    showDot = true
                }
            }
            // Fade in text
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeIn(duration: 0.5)) {
                    showText = true
                }
            }
        }
    }
}

// MARK: - Animated logo used on splash

struct AnimatedSkinrLogo: View {
    @Environment(\.colorScheme) private var colorScheme

    var size: CGFloat
    var ringProgress: CGFloat
    var showDot: Bool

    var body: some View {
        let logoColor: Color = (colorScheme == .dark) ? .skinrSoftSage : .skinrTeal

        ZStack {
            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(logoColor, style: StrokeStyle(lineWidth: size * 0.07, lineCap: .round))
                .rotationEffect(.degrees(-90)) // start at top
                .animation(nil, value: ringProgress)

            Circle()
                .fill(logoColor)
                .frame(width: size * 0.22, height: size * 0.22)
                .offset(y: size * 0.18)
                .opacity(showDot ? 1 : 0)
                .scaleEffect(showDot ? 1 : 0.3)
                .animation(nil, value: showDot)
        }
        .frame(width: size, height: size)
    }
}
