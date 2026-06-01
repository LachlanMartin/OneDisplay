#!/usr/bin/env swift

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let sizes = [16, 32, 64, 128, 256, 512]

let iconsetURL = URL(fileURLWithPath: "OneDisplay.iconset")
try? FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

func createIcon(size: Int, scale: Int) -> Data? {
    let w = size * scale
    let h = size * scale

    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(
        data: nil,
        width: w,
        height: h,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    context.setShouldAntialias(true)

    let cx = CGFloat(w) / 2
    let cy = CGFloat(h) / 2

    // --- Background: dark rounded square ---
    let bgRect = CGRect(x: 0, y: 0, width: w, height: h)
    let bgPath = CGPath(roundedRect: bgRect, cornerWidth: CGFloat(w) * 0.2, cornerHeight: CGFloat(h) * 0.2, transform: nil)
    context.addPath(bgPath)
    context.setFillColor(CGColor(srgbRed: 0.05, green: 0.05, blue: 0.08, alpha: 1))
    context.fillPath()

    // --- Base (keyboard deck) — seen from above, slightly angled ---
    let baseW = CGFloat(w) * 0.58
    let baseH = CGFloat(h) * 0.30
    let baseX = cx - baseW / 2
    let baseY = cy + CGFloat(h) * 0.02

    let baseCorner = baseW * 0.06
    let baseRect = CGRect(x: baseX, y: baseY, width: baseW, height: baseH)
    let basePath = CGPath(roundedRect: baseRect, cornerWidth: baseCorner, cornerHeight: baseCorner, transform: nil)
    context.addPath(basePath)
    context.setFillColor(CGColor(srgbRed: 0.78, green: 0.78, blue: 0.82, alpha: 1))
    context.fillPath()

    // --- Keyboard cutout area ---
    let kbPadH = baseW * 0.07
    let kbPadV = baseH * 0.1
    let kbRect = baseRect.insetBy(dx: kbPadH, dy: kbPadV)
    let kbPath = CGPath(roundedRect: kbRect, cornerWidth: kbRect.width * 0.025, cornerHeight: kbRect.height * 0.025, transform: nil)
    context.addPath(kbPath)
    context.setFillColor(CGColor(srgbRed: 0.15, green: 0.15, blue: 0.18, alpha: 1))
    context.fillPath()

    // --- Trackpad ---
    let tpW = kbRect.width * 0.40
    let tpH = kbRect.height * 0.26
    let tpX = kbRect.midX - tpW / 2
    let tpY = kbRect.maxY - tpH - kbPadV * 0.5
    let tpRect = CGRect(x: tpX, y: tpY, width: tpW, height: tpH)
    let tpPath = CGPath(roundedRect: tpRect, cornerWidth: tpW * 0.05, cornerHeight: tpH * 0.12, transform: nil)
    context.addPath(tpPath)
    context.setFillColor(CGColor(srgbRed: 0.35, green: 0.35, blue: 0.38, alpha: 1))
    context.fillPath()

    // --- Screen (lid) — trapezoid simulating perspective tilt ---
    let screenTopW = baseW * 0.60
    let screenBottomW = baseW * 0.82
    let screenH = CGFloat(h) * 0.46
    let screenTopY = cy - screenH * 0.52
    let screenBottomY = cy + CGFloat(h) * 0.04

    let screenPath = CGMutablePath()
    screenPath.move(to: CGPoint(x: cx - screenTopW / 2, y: screenTopY))
    screenPath.addLine(to: CGPoint(x: cx + screenTopW / 2, y: screenTopY))
    screenPath.addLine(to: CGPoint(x: cx + screenBottomW / 2, y: screenBottomY))
    screenPath.addLine(to: CGPoint(x: cx - screenBottomW / 2, y: screenBottomY))
    screenPath.closeSubpath()

    // Fill screen bezel (dark frame)
    context.addPath(screenPath)
    context.setFillColor(CGColor(srgbRed: 0.12, green: 0.12, blue: 0.14, alpha: 1))
    context.fillPath()

    // --- Inner screen (display area, slightly smaller) ---
    let displayInsetH = screenBottomW * 0.03
    let displayPath = CGMutablePath()
    displayPath.move(to: CGPoint(x: cx - screenTopW / 2 + displayInsetH * 1.5, y: screenTopY + displayInsetH * 1.8))
    displayPath.addLine(to: CGPoint(x: cx + screenTopW / 2 - displayInsetH * 1.5, y: screenTopY + displayInsetH * 1.8))
    displayPath.addLine(to: CGPoint(x: cx + screenBottomW / 2 - displayInsetH * 1.2, y: screenBottomY - displayInsetH))
    displayPath.addLine(to: CGPoint(x: cx - screenBottomW / 2 + displayInsetH * 1.2, y: screenBottomY - displayInsetH))
    displayPath.closeSubpath()

    context.saveGState()
    context.addPath(displayPath)
    context.clip()

    let displayGradient = CGGradient(
        colorsSpace: colorSpace,
        colors: [
            CGColor(srgbRed: 0, green: 0.55, blue: 0.95, alpha: 1) as CFTypeRef,
            CGColor(srgbRed: 0.3, green: 0.2, blue: 0.6, alpha: 1) as CFTypeRef
        ] as CFArray,
        locations: [0.0, 1.0]
    )!
    context.drawLinearGradient(displayGradient,
                               start: CGPoint(x: cx, y: screenTopY),
                               end: CGPoint(x: cx, y: screenBottomY),
                               options: [])
    context.restoreGState()

    // --- Subtle glare on display ---
    context.saveGState()
    context.addPath(displayPath)
    context.clip()
    let glareGradient = CGGradient(
        colorsSpace: colorSpace,
        colors: [
            CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.08) as CFTypeRef,
            CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0) as CFTypeRef
        ] as CFArray,
        locations: [0.0, 1.0]
    )!
    context.drawLinearGradient(glareGradient,
                               start: CGPoint(x: cx - screenBottomW * 0.2, y: screenBottomY - screenH * 0.15),
                               end: CGPoint(x: cx + screenBottomW * 0.2, y: screenTopY + screenH * 0.3),
                               options: [])
    context.restoreGState()

    // --- Hinge line (between screen and base) ---
    context.setStrokeColor(CGColor(srgbRed: 0.2, green: 0.2, blue: 0.22, alpha: 1))
    context.setLineWidth(CGFloat(w) * 0.012)
    context.move(to: CGPoint(x: cx - screenBottomW / 2 + displayInsetH, y: screenBottomY))
    context.addLine(to: CGPoint(x: cx + screenBottomW / 2 - displayInsetH, y: screenBottomY))
    context.strokePath()

    guard let cgImage = context.makeImage() else { return nil }

    let data = NSMutableData()
    let dest = CGImageDestinationCreateWithData(data as CFMutableData, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, cgImage, nil)
    CGImageDestinationFinalize(dest)

    return data as Data
}

for size in sizes {
    for scale in [1, 2] {
        let filename = "icon_\(size)x\(size)" + (scale == 2 ? "@2x.png" : ".png")
        if let data = createIcon(size: size, scale: scale) {
            try? data.write(to: iconsetURL.appendingPathComponent(filename))
        }
    }
}

print("Icon set generated at OneDisplay.iconset/")
