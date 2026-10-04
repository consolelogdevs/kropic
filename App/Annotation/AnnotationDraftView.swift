import KropicCore
import SwiftUI

/// Live preview of the shape being dragged, in view points. Blur and pixelate show their area.
struct AnnotationDraftView: View {
    let annotation: Annotation
    let pointsPerPixel: CGFloat

    var body: some View {
        let color = annotation.color.color
        let width = max(1, annotation.lineWidth * pointsPerPixel)
        switch annotation.kind {
        case .arrow(let start, let end):
            Path { path in
                path.move(to: point(start))
                path.addLine(to: point(end))
            }
            .stroke(color, style: StrokeStyle(lineWidth: width, lineCap: .round))
        case .rectangle(let rect):
            Rectangle().strokeBorder(color, lineWidth: width).frame(rect: self.rect(rect))
        case .highlight(let rect):
            Rectangle().fill(color.opacity(0.4)).frame(rect: self.rect(rect))
        case .blur(let rect), .pixelate(let rect):
            Rectangle()
                .fill(Color.black.opacity(0.15))
                .overlay(Rectangle().strokeBorder(Color.accent, style: StrokeStyle(lineWidth: 1.5, dash: [5, 3])))
                .frame(rect: self.rect(rect))
        case .text:
            EmptyView()
        }
    }

    private func point(_ pixel: CGPoint) -> CGPoint {
        CGPoint(x: pixel.x * pointsPerPixel, y: pixel.y * pointsPerPixel)
    }

    private func rect(_ pixel: CGRect) -> CGRect {
        CGRect(x: pixel.minX * pointsPerPixel, y: pixel.minY * pointsPerPixel,
               width: pixel.width * pointsPerPixel, height: pixel.height * pointsPerPixel)
    }
}

private extension View {
    /// Places a view at a rect inside a top-leading overlay.
    func frame(rect: CGRect) -> some View {
        frame(width: rect.width, height: rect.height).offset(x: rect.minX, y: rect.minY)
    }
}
