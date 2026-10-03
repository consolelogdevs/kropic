import CoreGraphics
import CoreText
import Foundation

/// Renders known text into an in-memory image, so OCR tests need no fixture files.
enum TestImage {
    static func render(_ text: String, fontSize: CGFloat = 16, scale: CGFloat = 2, dark: Bool = false) -> CGImage {
        let font = CTFontCreateUIFontForLanguage(.system, fontSize * scale, nil)!
        let foreground = CGColor(gray: dark ? 1 : 0, alpha: 1)
        let background = CGColor(gray: dark ? 0.12 : 1, alpha: 1)
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key(kCTFontAttributeName as String): font,
            NSAttributedString.Key(kCTForegroundColorAttributeName as String): foreground,
        ]
        let framesetter = CTFramesetterCreateWithAttributedString(NSAttributedString(string: text, attributes: attributes))
        let textSize = CTFramesetterSuggestFrameSizeWithConstraints(
            framesetter, CFRange(), nil, CGSize(width: 4000, height: CGFloat.greatestFiniteMagnitude), nil
        )

        let padding = 20 * scale
        let width = Int((textSize.width + padding * 2).rounded(.up))
        let height = Int((textSize.height + padding * 2).rounded(.up))
        let context = CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        context.setFillColor(background)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        let path = CGPath(rect: CGRect(x: padding, y: padding, width: textSize.width.rounded(.up), height: textSize.height.rounded(.up)), transform: nil)
        CTFrameDraw(CTFramesetterCreateFrame(framesetter, CFRange(), path, nil), context)
        return context.makeImage()!
    }
}
