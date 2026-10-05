import CoreGraphics
import CoreText
import Foundation

extension Annotation {
    /// The area the mark covers, including its stroke.
    public var bounds: CGRect {
        let pad = lineWidth / 2
        switch kind {
        case .arrow(let from, let to):
            return CGRect(x: min(from.x, to.x), y: min(from.y, to.y), width: abs(to.x - from.x), height: abs(to.y - from.y))
                .insetBy(dx: -lineWidth * 2, dy: -lineWidth * 2)
        case .pen(let points):
            guard let first = points.first else { return .null }
            return points.dropFirst().reduce(CGRect(origin: first, size: .zero)) { $0.union(CGRect(origin: $1, size: .zero)) }
                .insetBy(dx: -pad, dy: -pad)
        case .rectangle(let rect), .highlight(let rect), .blur(let rect), .pixelate(let rect):
            return rect.standardized
        case .text(let string, let origin, let fontSize):
            return CGRect(origin: origin, size: Self.textSize(string, fontSize: fontSize))
        }
    }

    /// Whether a point is on the mark: on the line for arrows, strokes and rectangle outlines,
    /// anywhere inside for filled areas and text.
    public func contains(_ point: CGPoint, tolerance: CGFloat) -> Bool {
        let reach = tolerance + lineWidth / 2
        switch kind {
        case .arrow(let from, let to):
            return Self.distance(from: point, toSegment: from, to) <= reach
        case .pen(let points):
            guard let first = points.first else { return false }
            if points.count == 1 { return hypot(point.x - first.x, point.y - first.y) <= reach }
            return zip(points, points.dropFirst()).contains { Self.distance(from: point, toSegment: $0, $1) <= reach }
        case .rectangle(let rect):
            let outer = rect.standardized.insetBy(dx: -reach, dy: -reach)
            let inner = rect.standardized.insetBy(dx: reach, dy: reach)
            return outer.contains(point) && !(inner.width > 0 && inner.height > 0 && inner.contains(point))
        case .highlight, .blur, .pixelate, .text:
            return bounds.insetBy(dx: -tolerance, dy: -tolerance).contains(point)
        }
    }

    /// The same mark shifted by `offset`.
    public func moved(by offset: CGSize) -> Annotation {
        func point(_ p: CGPoint) -> CGPoint { CGPoint(x: p.x + offset.width, y: p.y + offset.height) }
        func rect(_ r: CGRect) -> CGRect { r.offsetBy(dx: offset.width, dy: offset.height) }
        var copy = self
        switch kind {
        case .arrow(let from, let to): copy.kind = .arrow(from: point(from), to: point(to))
        case .pen(let points): copy.kind = .pen(points.map(point))
        case .rectangle(let r): copy.kind = .rectangle(rect(r))
        case .text(let string, let origin, let size): copy.kind = .text(string, origin: point(origin), fontSize: size)
        case .highlight(let r): copy.kind = .highlight(rect(r))
        case .blur(let r): copy.kind = .blur(rect(r))
        case .pixelate(let r): copy.kind = .pixelate(rect(r))
        }
        return copy
    }

    /// Size of text as `AnnotationRenderer` draws it.
    static func textSize(_ string: String, fontSize: CGFloat) -> CGSize {
        let font = CTFontCreateUIFontForLanguage(.emphasizedSystem, fontSize, nil)
            ?? CTFontCreateWithName("Helvetica-Bold" as CFString, fontSize, nil)
        let attributes = [NSAttributedString.Key(kCTFontAttributeName as String): font]
        let lines = string.components(separatedBy: .newlines)
        let width = lines.map { line in
            CGFloat(CTLineGetTypographicBounds(CTLineCreateWithAttributedString(NSAttributedString(string: line, attributes: attributes)), nil, nil, nil))
        }.max() ?? 0
        let lineHeight = CTFontGetAscent(font) + CTFontGetDescent(font) + CTFontGetLeading(font)
        return CGSize(width: width, height: lineHeight * CGFloat(lines.count))
    }

    private static func distance(from p: CGPoint, toSegment a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = b.x - a.x, dy = b.y - a.y
        let lengthSquared = dx * dx + dy * dy
        guard lengthSquared > 0 else { return hypot(p.x - a.x, p.y - a.y) }
        let t = max(0, min(1, ((p.x - a.x) * dx + (p.y - a.y) * dy) / lengthSquared))
        return hypot(p.x - (a.x + t * dx), p.y - (a.y + t * dy))
    }
}

extension Array where Element == Annotation {
    /// The topmost mark under a point, the one drawn last.
    public func topmost(at point: CGPoint, tolerance: CGFloat) -> Annotation? {
        last { $0.contains(point, tolerance: tolerance) }
    }
}
