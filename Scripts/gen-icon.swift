#!/usr/bin/env swift

import CoreGraphics
import CoreText
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

    let rect = CGRect(x: 0, y: 0, width: w, height: h)
    let cornerRadius = CGFloat(w) / 8
    let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    context.addPath(path)
    context.setFillColor(CGColor(srgbRed: 0, green: 0.48, blue: 1, alpha: 1))
    context.fillPath()

    let text = "1" as CFString
    let fontSize = CGFloat(w) * 0.6
    let font = CTFontCreateWithName("Helvetica" as CFString, fontSize, nil)
    let attributes = [
        kCTFontAttributeName: font,
        kCTForegroundColorAttributeName: CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1)
    ] as CFDictionary
    let attrString = CFAttributedStringCreate(nil, text, attributes)!
    let line = CTLineCreateWithAttributedString(attrString)

    let textBounds = CTLineGetImageBounds(line, context)
    let textX = (CGFloat(w) - textBounds.width) / 2 - textBounds.origin.x
    let textY = (CGFloat(h) - textBounds.height) / 2 - textBounds.origin.y

    context.textPosition = CGPoint(x: textX, y: textY)
    CTLineDraw(line, context)

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
