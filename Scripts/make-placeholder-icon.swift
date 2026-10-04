// Renders Kropic's placeholder app icon into App/Resources/Assets.xcassets/AppIcon.appiconset.
// Plain shapes only: SF Symbols may not be used in app icons.
// Run from the repo root: swift Scripts/make-placeholder-icon.swift

import AppKit

let outputDirectory = URL(fileURLWithPath: "App/Resources/Assets.xcassets/AppIcon.appiconset")

func render(pixels: Int) -> Data {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let context = NSGraphicsContext.current!.cgContext
    // Draw on a 1024 grid and scale to the target size.
    context.scaleBy(x: CGFloat(pixels) / 1024, y: CGFloat(pixels) / 1024)

    // Body: the macOS icon grid's 824 pt rounded square, with a soft shadow.
    let body = CGRect(x: 100, y: 100, width: 824, height: 824)
    let bodyPath = CGPath(roundedRect: body, cornerWidth: 185, cornerHeight: 185, transform: nil)
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -12), blur: 28, color: CGColor(gray: 0, alpha: 0.3))
    context.addPath(bodyPath)
    context.setFillColor(CGColor(red: 0.0, green: 0.38, blue: 0.80, alpha: 1))
    context.fillPath()
    context.restoreGState()

    context.saveGState()
    context.addPath(bodyPath)
    context.clip()
    // The design's accent blue (#0062CC), slightly lighter at the top.
    let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 0.10, green: 0.47, blue: 0.88, alpha: 1),
            CGColor(red: 0.0, green: 0.38, blue: 0.80, alpha: 1),
        ] as CFArray,
        locations: [0, 1]
    )!
    context.drawLinearGradient(gradient, start: CGPoint(x: 512, y: 924), end: CGPoint(x: 512, y: 100), options: [])
    context.restoreGState()

    // Crop glyph, the same shape as the onboarding tile and the menu bar icon:
    // two overlapping right angles on a 16-unit grid ("M4 1v11h11" and "M1 4h11v11").
    let unit: CGFloat = 30
    let origin = CGPoint(x: 512 - 8 * unit, y: 512 + 8 * unit)
    func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: origin.x + x * unit, y: origin.y - y * unit)
    }
    context.setStrokeColor(CGColor(gray: 1, alpha: 1))
    context.setLineWidth(1.6 * unit)
    context.setLineCap(.round)
    context.setLineJoin(.round)
    context.move(to: point(4, 1))
    context.addLine(to: point(4, 12))
    context.addLine(to: point(15, 12))
    context.move(to: point(1, 4))
    context.addLine(to: point(12, 4))
    context.addLine(to: point(12, 15))
    context.strokePath()

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

// macOS icon slots: (point size, scale).
let slots: [(Int, Int)] = [(16, 1), (16, 2), (32, 1), (32, 2), (128, 1), (128, 2), (256, 1), (256, 2), (512, 1), (512, 2)]
var images: [[String: String]] = []
for (points, scale) in slots {
    let filename = "icon_\(points)x\(points)\(scale == 2 ? "@2x" : "").png"
    try render(pixels: points * scale).write(to: outputDirectory.appendingPathComponent(filename))
    images.append(["idiom": "mac", "size": "\(points)x\(points)", "scale": "\(scale)x", "filename": filename])
}
let contents: [String: Any] = ["images": images, "info": ["author": "xcode", "version": 1]]
let json = try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
try json.write(to: outputDirectory.appendingPathComponent("Contents.json"))
print("Wrote \(slots.count) icon sizes to \(outputDirectory.path)")
