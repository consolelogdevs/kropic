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
    context.setFillColor(CGColor(red: 0.23, green: 0.25, blue: 0.85, alpha: 1))
    context.fillPath()
    context.restoreGState()

    context.saveGState()
    context.addPath(bodyPath)
    context.clip()
    let gradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [
            CGColor(red: 0.33, green: 0.52, blue: 1.0, alpha: 1),
            CGColor(red: 0.23, green: 0.25, blue: 0.85, alpha: 1),
        ] as CFArray,
        locations: [0, 1]
    )!
    context.drawLinearGradient(gradient, start: CGPoint(x: 512, y: 924), end: CGPoint(x: 512, y: 100), options: [])
    context.restoreGState()

    // Viewfinder corners.
    context.setStrokeColor(CGColor(gray: 1, alpha: 1))
    context.setLineWidth(46)
    context.setLineCap(.round)
    context.setLineJoin(.round)
    let frame = CGRect(x: 260, y: 260, width: 504, height: 504)
    let arm: CGFloat = 130
    let corners: [(CGPoint, CGFloat, CGFloat)] = [
        (CGPoint(x: frame.minX, y: frame.maxY), 1, -1),
        (CGPoint(x: frame.maxX, y: frame.maxY), -1, -1),
        (CGPoint(x: frame.minX, y: frame.minY), 1, 1),
        (CGPoint(x: frame.maxX, y: frame.minY), -1, 1),
    ]
    for (corner, dx, dy) in corners {
        context.move(to: CGPoint(x: corner.x + dx * arm, y: corner.y))
        context.addLine(to: corner)
        context.addLine(to: CGPoint(x: corner.x, y: corner.y + dy * arm))
    }
    context.strokePath()

    // Three text lines.
    context.setFillColor(CGColor(gray: 1, alpha: 1))
    let lines: [(y: CGFloat, width: CGFloat)] = [(586, 300), (494, 300), (402, 190)]
    for line in lines {
        let rect = CGRect(x: 362, y: line.y, width: line.width, height: 44)
        context.addPath(CGPath(roundedRect: rect, cornerWidth: 22, cornerHeight: 22, transform: nil))
    }
    context.fillPath()

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
