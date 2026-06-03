#!/usr/bin/env swift

import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

let w = 1280
let h = 640

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

// Dark background
context.setFillColor(CGColor(srgbRed: 0.05, green: 0.05, blue: 0.08, alpha: 1))
context.fill(CGRect(x: 0, y: 0, width: w, height: h))

// Load the icon
guard let source = CGImageSourceCreateWithURL(
    URL(fileURLWithPath: "Resources/laptop-icon-input.png") as CFURL, nil
) else { exit(1) }
guard let original = CGImageSourceCreateImageAtIndex(source, 0, nil) else { exit(1) }

let iconSize: CGFloat = 200
let iconX = (CGFloat(w) - iconSize) / 2
let iconY: CGFloat = 180
context.interpolationQuality = .high
context.draw(original, in: CGRect(x: iconX, y: iconY, width: iconSize, height: iconSize))

// Title
let title = "OneDisplay" as CFString
let titleFont = CTFontCreateWithName("Helvetica" as CFString, 56, nil)
let titleAttrs = [
    kCTFontAttributeName: titleFont,
    kCTForegroundColorAttributeName: CGColor(srgbRed: 0.85, green: 0.85, blue: 0.87, alpha: 1)
] as CFDictionary
let titleAttrString = CFAttributedStringCreate(nil as CFAllocator?, title, titleAttrs)!
let titleLine = CTLineCreateWithAttributedString(titleAttrString)
let titleBounds = CTLineGetImageBounds(titleLine, context)
let titleX = (CGFloat(w) - titleBounds.width) / 2 - titleBounds.origin.x
let titleY: CGFloat = 420
context.textPosition = CGPoint(x: titleX, y: titleY)
CTLineDraw(titleLine, context)

// Subtitle
let subtitle = "One display at a time." as CFString
let subFont = CTFontCreateWithName("Helvetica" as CFString, 24, nil)
let subAttrs = [
    kCTFontAttributeName: subFont,
    kCTForegroundColorAttributeName: CGColor(srgbRed: 0.5, green: 0.5, blue: 0.55, alpha: 1)
] as CFDictionary
let subAttrString = CFAttributedStringCreate(nil as CFAllocator?, subtitle, subAttrs)!
let subLine = CTLineCreateWithAttributedString(subAttrString)
let subBounds = CTLineGetImageBounds(subLine, context)
let subX = (CGFloat(w) - subBounds.width) / 2 - subBounds.origin.x
let subY: CGFloat = 370
context.textPosition = CGPoint(x: subX, y: subY)
CTLineDraw(subLine, context)

let cgImage = context.makeImage()!
let data = NSMutableData()
let dest = CGImageDestinationCreateWithData(data as CFMutableData, UTType.png.identifier as CFString, 1, nil as CFDictionary?)!
CGImageDestinationAddImage(dest, cgImage, nil as CFDictionary?)
CGImageDestinationFinalize(dest)
try? (data as Data).write(to: URL(fileURLWithPath: "Resources/social-preview.png"))

print("Social preview generated at Resources/social-preview.png")
