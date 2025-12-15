// ViewToImage.swift

import SwiftUI

extension View {
    func asImage(rect: CGRect) -> UIImage {
        let controller = UIHostingController(rootView: self)
        controller.view.frame = rect
        controller.view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { ctx in
            controller.view.layer.render(in: ctx.cgContext)
        }
    }
}
