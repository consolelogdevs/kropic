import CoreGraphics

extension Annotation {
    /// The same mark in another coordinate space: `origin` becomes (0, 0) and everything is
    /// multiplied by `scale`. Used to turn marks drawn in screen points into image pixels.
    public func converted(origin: CGPoint, scale: CGFloat) -> Annotation {
        func point(_ p: CGPoint) -> CGPoint {
            CGPoint(x: (p.x - origin.x) * scale, y: (p.y - origin.y) * scale)
        }
        func rect(_ r: CGRect) -> CGRect {
            CGRect(x: (r.minX - origin.x) * scale, y: (r.minY - origin.y) * scale, width: r.width * scale, height: r.height * scale)
        }
        var copy = self
        copy.lineWidth = lineWidth * scale
        switch kind {
        case .arrow(let from, let to): copy.kind = .arrow(from: point(from), to: point(to))
        case .pen(let points): copy.kind = .pen(points.map(point))
        case .rectangle(let r): copy.kind = .rectangle(rect(r))
        case .text(let string, let o, let size): copy.kind = .text(string, origin: point(o), fontSize: size * scale)
        case .highlight(let r): copy.kind = .highlight(rect(r))
        case .blur(let r): copy.kind = .blur(rect(r))
        case .pixelate(let r): copy.kind = .pixelate(rect(r))
        }
        return copy
    }
}
