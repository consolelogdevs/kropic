import CoreGraphics
import CoreText
import Foundation

/// Draws annotations into a copy of an image, in memory. The original image is not changed.
public enum AnnotationRenderer {
    /// Blur shrinks the area so its shorter side is about this many pixels before scaling back.
    static let blurSamples: CGFloat = 6
    /// Pixelate blocks are this fraction of the area's shorter side, at least `minimumBlock` pixels.
    static let pixelateFraction: CGFloat = 1.0 / 8
    static let minimumBlock: CGFloat = 8

    public static func render(_ annotations: [Annotation], onto image: CGImage) -> CGImage? {
        let width = image.width
        let height = image.height
        guard let space = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              )
        else { return nil }

        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        context.draw(image, in: bounds)
        // Annotations use a top-left origin like the image's pixels.
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)

        for annotation in annotations {
            context.saveGState()
            draw(annotation, in: context, source: image, bounds: bounds)
            context.restoreGState()
        }
        return context.makeImage()
    }

    private static func draw(_ annotation: Annotation, in context: CGContext, source: CGImage, bounds: CGRect) {
        let color = annotation.color.cgColor()
        switch annotation.kind {
        case .rectangle(let rect):
            context.setStrokeColor(color)
            context.setLineWidth(annotation.lineWidth)
            context.setLineJoin(.round)
            context.stroke(rect.standardized.insetBy(dx: annotation.lineWidth / 2, dy: annotation.lineWidth / 2))

        case .arrow(let start, let end):
            drawArrow(from: start, to: end, width: annotation.lineWidth, color: color, in: context)

        case .highlight(let rect):
            context.setBlendMode(.multiply)
            context.setFillColor(annotation.color.cgColor(alpha: 0.4))
            context.fill(rect.standardized)

        case .text(let string, let origin, let fontSize):
            drawText(string, at: origin, fontSize: fontSize, color: color, in: context)

        case .blur(let rect):
            redact(rect, in: context, source: source, bounds: bounds, smooth: true) { area in
                max(1, (min(area.width, area.height) / blurSamples).rounded())
            }

        case .pixelate(let rect):
            redact(rect, in: context, source: source, bounds: bounds, smooth: false) { area in
                max(minimumBlock, (min(area.width, area.height) * pixelateFraction).rounded())
            }
        }
    }

    private static func drawArrow(from start: CGPoint, to end: CGPoint, width: CGFloat, color: CGColor, in context: CGContext) {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let length = hypot(dx, dy)
        guard length > 0 else { return }
        let headLength = min(max(width * 4, 12), length)
        let angle = atan2(dy, dx)
        let spread = CGFloat.pi / 7
        let base = CGPoint(x: end.x - cos(angle) * headLength * 0.8, y: end.y - sin(angle) * headLength * 0.8)

        context.setStrokeColor(color)
        context.setFillColor(color)
        context.setLineWidth(width)
        context.setLineCap(.round)
        context.move(to: start)
        context.addLine(to: base)
        context.strokePath()

        context.move(to: end)
        context.addLine(to: CGPoint(x: end.x - cos(angle - spread) * headLength, y: end.y - sin(angle - spread) * headLength))
        context.addLine(to: CGPoint(x: end.x - cos(angle + spread) * headLength, y: end.y - sin(angle + spread) * headLength))
        context.closePath()
        context.fillPath()
    }

    private static func drawText(_ string: String, at origin: CGPoint, fontSize: CGFloat, color: CGColor, in context: CGContext) {
        let font = CTFontCreateUIFontForLanguage(.emphasizedSystem, fontSize, nil)
            ?? CTFontCreateWithName("Helvetica-Bold" as CFString, fontSize, nil)
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key(kCTFontAttributeName as String): font,
            NSAttributedString.Key(kCTForegroundColorAttributeName as String): color,
        ]
        // The context is flipped, so glyphs are flipped back.
        context.textMatrix = CGAffineTransform(scaleX: 1, y: -1)
        var y = origin.y + CTFontGetAscent(font)
        let lineHeight = CTFontGetAscent(font) + CTFontGetDescent(font) + CTFontGetLeading(font)
        for line in string.components(separatedBy: .newlines) {
            context.textPosition = CGPoint(x: origin.x, y: y)
            CTLineDraw(CTLineCreateWithAttributedString(NSAttributedString(string: line, attributes: attributes)), context)
            y += lineHeight
        }
    }

    /// Shrinks the area to a few samples and scales it back up: with smoothing that is a strong
    /// blur, without it a pixelation. Either way the original detail is gone from the output.
    private static func redact(
        _ rect: CGRect,
        in context: CGContext,
        source: CGImage,
        bounds: CGRect,
        smooth: Bool,
        blockSize: (CGRect) -> CGFloat
    ) {
        let area = rect.standardized.integral.intersection(bounds)
        guard !area.isEmpty, let crop = source.cropping(to: area) else { return }
        let block = blockSize(area)
        let smallWidth = max(1, Int((area.width / block).rounded(.up)))
        let smallHeight = max(1, Int((area.height / block).rounded(.up)))
        guard let space = CGColorSpace(name: CGColorSpace.sRGB),
              let small = CGContext(
                data: nil, width: smallWidth, height: smallHeight, bitsPerComponent: 8, bytesPerRow: 0,
                space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              )
        else { return }
        small.interpolationQuality = .high
        small.draw(crop, in: CGRect(x: 0, y: 0, width: smallWidth, height: smallHeight))
        guard let reduced = small.makeImage() else { return }

        // Images draw upright only in an unflipped space, so undo the flip around the area.
        context.interpolationQuality = smooth ? .high : .none
        context.translateBy(x: area.minX, y: area.maxY)
        context.scaleBy(x: 1, y: -1)
        context.draw(reduced, in: CGRect(origin: .zero, size: area.size))
    }
}
