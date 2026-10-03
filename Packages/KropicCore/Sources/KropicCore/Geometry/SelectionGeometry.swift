import CoreGraphics

/// Pure selection math. All rects are display-local: points, origin top-left, y grows downward.
public enum SelectionGeometry {
    /// The rectangle spanned by two points, clamped to `bounds`. Works in any drag direction.
    public static func rect(from start: CGPoint, to end: CGPoint, within bounds: CGRect) -> CGRect {
        let a = clamp(start, to: bounds)
        let b = clamp(end, to: bounds)
        return CGRect(x: min(a.x, b.x), y: min(a.y, b.y), width: abs(a.x - b.x), height: abs(a.y - b.y))
    }

    /// `rect` shifted by `delta`, kept fully inside `bounds` without changing its size.
    public static func moved(_ rect: CGRect, by delta: CGSize, within bounds: CGRect) -> CGRect {
        let x = min(max(rect.minX + delta.width, bounds.minX), bounds.maxX - rect.width)
        let y = min(max(rect.minY + delta.height, bounds.minY), bounds.maxY - rect.height)
        return CGRect(x: x, y: y, width: rect.width, height: rect.height)
    }

    /// `rect` with the edges belonging to `handle` moved to `point`. Dragging past the
    /// opposite edge flips the rectangle instead of producing a negative size.
    public static func resized(_ rect: CGRect, handle: SelectionHandle, to point: CGPoint, within bounds: CGRect) -> CGRect {
        let p = clamp(point, to: bounds)
        var minX = rect.minX, maxX = rect.maxX, minY = rect.minY, maxY = rect.maxY
        switch handle {
        case .topLeft: minX = p.x; minY = p.y
        case .top: minY = p.y
        case .topRight: maxX = p.x; minY = p.y
        case .right: maxX = p.x
        case .bottomRight: maxX = p.x; maxY = p.y
        case .bottom: maxY = p.y
        case .bottomLeft: minX = p.x; maxY = p.y
        case .left: minX = p.x
        }
        return self.rect(from: CGPoint(x: minX, y: minY), to: CGPoint(x: maxX, y: maxY), within: bounds)
    }

    /// Where a handle sits on `rect`.
    public static func point(of handle: SelectionHandle, in rect: CGRect) -> CGPoint {
        switch handle {
        case .topLeft: CGPoint(x: rect.minX, y: rect.minY)
        case .top: CGPoint(x: rect.midX, y: rect.minY)
        case .topRight: CGPoint(x: rect.maxX, y: rect.minY)
        case .right: CGPoint(x: rect.maxX, y: rect.midY)
        case .bottomRight: CGPoint(x: rect.maxX, y: rect.maxY)
        case .bottom: CGPoint(x: rect.midX, y: rect.maxY)
        case .bottomLeft: CGPoint(x: rect.minX, y: rect.maxY)
        case .left: CGPoint(x: rect.minX, y: rect.midY)
        }
    }

    /// The handle under `point`, if any. Corners win over edges, and edges are grabbable
    /// along their whole length, not only at the visible midpoint handle.
    public static func handle(at point: CGPoint, in rect: CGRect, tolerance: CGFloat) -> SelectionHandle? {
        let nearLeft = abs(point.x - rect.minX) <= tolerance
        let nearRight = abs(point.x - rect.maxX) <= tolerance
        let nearTop = abs(point.y - rect.minY) <= tolerance
        let nearBottom = abs(point.y - rect.maxY) <= tolerance
        let withinX = point.x >= rect.minX - tolerance && point.x <= rect.maxX + tolerance
        let withinY = point.y >= rect.minY - tolerance && point.y <= rect.maxY + tolerance

        if nearTop && nearLeft { return .topLeft }
        if nearTop && nearRight { return .topRight }
        if nearBottom && nearRight { return .bottomRight }
        if nearBottom && nearLeft { return .bottomLeft }
        if nearTop && withinX { return .top }
        if nearBottom && withinX { return .bottom }
        if nearLeft && withinY { return .left }
        if nearRight && withinY { return .right }
        return nil
    }

    static func clamp(_ point: CGPoint, to bounds: CGRect) -> CGPoint {
        CGPoint(
            x: min(max(point.x, bounds.minX), bounds.maxX),
            y: min(max(point.y, bounds.minY), bounds.maxY)
        )
    }
}
