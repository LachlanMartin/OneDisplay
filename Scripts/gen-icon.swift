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

    // Load source image and scale it
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
    context.draw(original, in: CGRect(x: 0, y: 0, width: w, height: h))

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
