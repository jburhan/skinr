// SkinAnalyzer.swift
import UIKit
import CoreGraphics

final class SkinAnalyzer {

    // Public entrypoint
    func analyze(
        image: UIImage,
        pigScale: Double = 1.0,
        redScale: Double = 1.0
    ) -> SkinAnalysisResult? {
        // 1) Normalize orientation
        guard let fixedImage = image.fixedOrientation(),
              let cgImage = fixedImage.cgImage else {
            return nil
        }

        let width = cgImage.width
        let height = cgImage.height

        if width != 1440 || height != 1440 {
            print("Warning: expected 1440x1440, got \(width)x\(height)")
        }

        // 2) Get RGBA pixel buffer
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = bytesPerRow * height
        let totalPixels = width * height

        var pixels = [UInt8](repeating: 0, count: totalBytes)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // 3) Compute grayscale and simple normalization
        var gray = [UInt8](repeating: 0, count: totalPixels)

        var sumGray: Double = 0.0
        for y in 0..<height {
            for x in 0..<width {
                let idx = y * bytesPerRow + x * bytesPerPixel
                let r = Double(pixels[idx + 0])
                let g = Double(pixels[idx + 1])
                let b = Double(pixels[idx + 2])

                // Standard luma approximation
                let gVal = 0.299 * r + 0.587 * g + 0.114 * b
                let gi = UInt8(clamping: Int(gVal.rounded()))
                gray[y * width + x] = gi
                sumGray += gVal
            }
        }

        // Normalize brightness so mean ~ 128
        let meanGray = sumGray / Double(totalPixels)
        let scaleNorm = meanGray > 0 ? 128.0 / meanGray : 1.0

        for i in 0..<gray.count {
            let val = Double(gray[i]) * scaleNorm
            gray[i] = UInt8(clamping: Int(val.rounded()))
        }

        // ROI: central elliptical region (approximate face)
        let roiMask = makeROIMask(width: width, height: height)

        // 4) Pigmentation mask via percentile on normalized grayscale (darkest ~30%)
        var pigMask = computePigmentationMask(
            gray: gray,
            width: width,
            height: height,
            percentile: 10.0
        )

        // 5) Redness mask via HSV threshold on original pixels
        var redMask = computeRednessMask(
            pixels: pixels,
            width: width,
            height: height,
            bytesPerRow: bytesPerRow
        )

        // Restrict both masks to ROI only
        for i in 0..<totalPixels {
            if !roiMask[i] {
                pigMask[i] = false
                redMask[i] = false
            }
        }

        // 6) Scores with scaling
        let pigScore = scoreFromMask(mask: pigMask, scale: pigScale)
        let redScore = scoreFromMask(mask: redMask, scale: redScale)

        // 7) Build overlay image
        guard let overlayImage = makeOverlayImage(
            basePixels: pixels,
            pigMask: pigMask,
            redMask: redMask,
            width: width,
            height: height,
            bytesPerRow: bytesPerRow,
            colorSpace: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        return SkinAnalysisResult(
            pigmentationScore: pigScore,
            rednessScore: redScore,
            overlayImage: overlayImage
        )
    }

    // MARK: - ROI

    /// Simple central ellipse ROI to approximate the face and ignore background.
    private func makeROIMask(width: Int, height: Int) -> [Bool] {
        var mask = [Bool](repeating: false, count: width * height)

        let cx = Double(width) / 2.0
        let cy = Double(height) / 2.0

        // Radii: adjust to taste
        let rx = Double(width) * 0.35
        let ry = Double(height) * 0.45

        for y in 0..<height {
            for x in 0..<width {
                let dx = (Double(x) - cx) / rx
                let dy = (Double(y) - cy) / ry
                let inside = (dx * dx + dy * dy) <= 1.0
                mask[y * width + x] = inside
            }
        }
        return mask
    }

    // MARK: - Pigmentation

    private func computePigmentationMask(
        gray: [UInt8],
        width: Int,
        height: Int,
        percentile: Double
    ) -> [Bool] {
        let totalPixels = gray.count

        // Build histogram
        var hist = [Int](repeating: 0, count: 256)
        for v in gray {
            hist[Int(v)] += 1
        }

        // Threshold at given percentile (e.g. 30%)
        let targetCount = Int(Double(totalPixels) * percentile / 100.0)
        var cumulative = 0
        var threshold: Int = 128
        for i in 0..<256 {
            cumulative += hist[i]
            if cumulative >= targetCount {
                threshold = i
                break
            }
        }

        // Darker than threshold => pigmentation
        var mask = [Bool](repeating: false, count: totalPixels)
        for i in 0..<totalPixels {
            // Slightly stricter than threshold
            mask[i] = Int(gray[i]) < (threshold - 5)
        }

        return mask
    }

    // MARK: - Redness

    private func computeRednessMask(
        pixels: [UInt8],
        width: Int,
        height: Int,
        bytesPerRow: Int
    ) -> [Bool] {
        let totalPixels = width * height
        var mask = [Bool](repeating: false, count: totalPixels)

        for y in 0..<height {
            for x in 0..<width {
                let pIndex = y * bytesPerRow + x * 4
                let r = Double(pixels[pIndex + 0]) / 255.0
                let g = Double(pixels[pIndex + 1]) / 255.0
                let b = Double(pixels[pIndex + 2]) / 255.0

                let (h, s, v) = rgbToHSV(r: r, g: g, b: b)

                // Narrower hue range and higher saturation/brightness
                let isRedHue = (h >= 0 && h <= 18) || (h >= 345 && h <= 360)
                let isSat = s > 0.18
                let isVal = v > 0.25

                // Require red channel to be clearly dominant
                let isRedDominant = (r > g + 0.05) && (r > b + 0.05)

                let idx = y * width + x
                mask[idx] = isRedHue && isSat && isVal && isRedDominant
            }
        }

        return mask
    }


    // RGB [0..1] -> HSV
    private func rgbToHSV(r: Double, g: Double, b: Double) -> (h: Double, s: Double, v: Double) {
        let maxVal = max(r, g, b)
        let minVal = min(r, g, b)
        let delta = maxVal - minVal

        var h: Double = 0
        let v = maxVal
        let s = (maxVal == 0) ? 0 : (delta / maxVal)

        if delta == 0 {
            h = 0
        } else if maxVal == r {
            h = 60 * (((g - b) / delta).truncatingRemainder(dividingBy: 6))
        } else if maxVal == g {
            h = 60 * (((b - r) / delta) + 2)
        } else {
            h = 60 * (((r - g) / delta) + 4)
        }

        if h < 0 { h += 360 }

        return (h, s, v)
    }

    // MARK: - Scoring

    private func scoreFromMask(mask: [Bool], scale: Double) -> Int {
        let total = mask.count
        guard total > 0 else { return 0 }

        let positive = mask.reduce(0) { $0 + ($1 ? 1 : 0) }
        if positive == 0 { return 0 }

        let frac = Double(positive) / Double(total) // 0..1
        let raw = frac * 100.0 * scale
        let clamped = min(raw, 100.0)

        if clamped < 1.0 {
            return 1
        }
        return Int(clamped.rounded())
    }

    // MARK: - Overlay

    private func makeOverlayImage(
        basePixels: [UInt8],
        pigMask: [Bool],
        redMask: [Bool],
        width: Int,
        height: Int,
        bytesPerRow: Int,
        colorSpace: CGColorSpace,
        bitmapInfo: UInt32
    ) -> UIImage? {
        var overlayPixels = basePixels

        let alpha: Double = 0.4
        let green = (r: 0.0, g: 255.0, b: 0.0)
        let red = (r: 255.0, g: 0.0, b: 0.0)

        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = y * bytesPerRow + x * 4
                let maskIndex = y * width + x

                let applyGreen = pigMask[maskIndex]
                let applyRed = redMask[maskIndex]

                if !applyGreen && !applyRed {
                    continue
                }

                var r = Double(overlayPixels[pixelIndex + 0])
                var g = Double(overlayPixels[pixelIndex + 1])
                var b = Double(overlayPixels[pixelIndex + 2])

                if applyGreen {
                    r = (1.0 - alpha) * r + alpha * green.r
                    g = (1.0 - alpha) * g + alpha * green.g
                    b = (1.0 - alpha) * b + alpha * green.b
                }

                if applyRed {
                    r = (1.0 - alpha) * r + alpha * red.r
                    g = (1.0 - alpha) * g + alpha * red.g
                    b = (1.0 - alpha) * b + alpha * red.b
                }

                overlayPixels[pixelIndex + 0] = UInt8(clamping: Int(r.rounded()))
                overlayPixels[pixelIndex + 1] = UInt8(clamping: Int(g.rounded()))
                overlayPixels[pixelIndex + 2] = UInt8(clamping: Int(b.rounded()))
            }
        }

        guard let ctx = CGContext(
            data: &overlayPixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ), let outCG = ctx.makeImage() else {
            return nil
        }

        return UIImage(cgImage: outCG, scale: 1.0, orientation: .up)
    }
}

// MARK: - UIImage extension and result struct (unchanged)

extension UIImage {
    func fixedOrientation() -> UIImage? {
        if imageOrientation == .up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}

struct SkinAnalysisResult {
    let pigmentationScore: Int
    let rednessScore: Int
    let overlayImage: UIImage
}
