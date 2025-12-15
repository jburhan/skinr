//  SkinrBrand.swift

import SwiftUI

// MARK: - Brand Colors

extension Color {
    static let skinrTeal = Color(red: 64/255, green: 184/255, blue: 176/255)   // #40B8B0
    static let skinrCharcoal = Color(red: 17/255, green: 24/255, blue: 39/255) // #111827
    static let skinrOffWhite = Color(red: 245/255, green: 245/255, blue: 247/255) // #F5F5F7
    static let skinrAccentCoral = Color(red: 249/255, green: 115/255, blue: 98/255) // #F97362
    static let skinrSoftSage = Color(red: 183/255, green: 228/255, blue: 199/255) // #B7E4C7
}

// MARK: - Logo

struct SkinrLogoView: View {
    var size: CGFloat = 44

    var body: some View {
        let logoColor: Color = .skinrTeal

        ZStack {
            Circle()
                .stroke(logoColor, lineWidth: size * 0.07)

            Circle()
                .fill(logoColor)
                .frame(width: size * 0.22, height: size * 0.22)
                .offset(y: size * 0.18)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Brand Header (optional reusable)

struct SkinrBrandHeader: View {
    var body: some View {
        HStack(spacing: 12) {
            SkinrLogoView(size: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text("SkinR")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.skinrCharcoal)

                Text("Beauty is science.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.top, 4)
    }
}
