import KropicCore
import SwiftUI

/// Draws one annotation for on-screen preview, in a top-leading overlay. Coordinates are
/// multiplied by `pointsPerUnit` (1 when the annotation is already in points). Blur and
/// pixelate show a frosted area here; the real effect is applied to the captured image.
struct AnnotationShapeView: View {
    let annotation: Annotation
    var pointsPerUnit: CGFloat = 1

    var body: some View {
        let color = annotation.color.color
        let width = max(1, annotation.lineWidth * pointsPerUnit)
        switch annotation.kind {
        case .arrow(let start, let end):
            ArrowShape(start: point(start), end: point(end), lineWidth: width)
                .fill(color)
        case .rectangle(let rect):
            Rectangle().strokeBorder(color, lineWidth: width).placed(in: self.rect(rect))
        case .highlight(let rect):
            Rectangle().fill(color.opacity(0.4)).placed(in: self.rect(rect))
        case .text(let string, let origin, let fontSize):
            Text(verbatim: string)
                .font(.system(size: fontSize * pointsPerUnit, weight: .bold))
                .foregroundStyle(color)
                .fixedSize()
                .offset(x: origin.x * pointsPerUnit, y: origin.y * pointsPerUnit)
        case .blur(let rect), .pixelate(let rect):
            BehindWindowBlur()
                .overlay(Rectangle().strokeBorder(.white.opacity(0.7), style: StrokeStyle(lineWidth: 1, dash: [4, 3])))
                .placed(in: self.rect(rect))
        }
    }

    private func point(_ p: CGPoint) -> CGPoint {
        CGPoint(x: p.x * pointsPerUnit, y: p.y * pointsPerUnit)
    }

    private func rect(_ r: CGRect) -> CGRect {
        CGRect(x: r.minX * pointsPerUnit, y: r.minY * pointsPerUnit, width: r.width * pointsPerUnit, height: r.height * pointsPerUnit)
    }
}

/// A line with a filled head, matching `AnnotationRenderer`'s arrow.
private struct ArrowShape: Shape {
    let start: CGPoint
    let end: CGPoint
    let lineWidth: CGFloat

    func path(in rect: CGRect) -> Path {
        let dx = end.x - start.x, dy = end.y - start.y
        let length = hypot(dx, dy)
        guard length > 0 else { return Path() }
        let headLength = min(max(lineWidth * 4, 12), length)
        let angle = atan2(dy, dx)
        let spread = CGFloat.pi / 7
        let base = CGPoint(x: end.x - cos(angle) * headLength * 0.8, y: end.y - sin(angle) * headLength * 0.8)
        var path = Path()
        path.move(to: start)
        path.addLine(to: base)
        path = path.strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        path.move(to: end)
        path.addLine(to: CGPoint(x: end.x - cos(angle - spread) * headLength, y: end.y - sin(angle - spread) * headLength))
        path.addLine(to: CGPoint(x: end.x - cos(angle + spread) * headLength, y: end.y - sin(angle + spread) * headLength))
        path.closeSubpath()
        return path
    }
}

private extension View {
    /// Places a view at `rect` inside a top-leading overlay.
    func placed(in rect: CGRect) -> some View {
        frame(width: rect.width, height: rect.height).offset(x: rect.minX, y: rect.minY)
    }
}
