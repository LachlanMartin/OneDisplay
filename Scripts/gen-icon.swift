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

    guard let source = CGImageSourceCreateWithURL(
        URL(fileURLWithPath: "Resources/laptop-icon-input.png") as CFURL, nil
    ) else { return nil }

    guard let original = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return nil }

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
    context.interpolationQuality = .high

    // Dark rounded rect background
    let corner = CGFloat(w) * 0.2
    let bgRect = CGRect(x: 0, y: 0, width: w, height: h)
    let bgPath = CGPath(roundedRect: bgRect, cornerWidth: corner, cornerHeight: corner, transform: nil)
    context.addPath(bgPath)
    context.setFillColor(CGColor(srgbRed: 0.05, green: 0.05, blue: 0.08, alpha: 1))
    context.fillPath()

    // Draw icon in white using the input image as a mask
    let iconRect = CGRect(x: 0, y: 0, width: w, height: h)
    context.saveGState()
    context.clip(to: iconRect, mask: original)
    context.setFillColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1))
    context.fill(iconRect)
    context.restoreGState()

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
