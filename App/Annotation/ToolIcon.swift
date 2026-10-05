import SwiftUI

/// The icon for a tool on the dark capture toolbar. Highlight, blur and pixelate are drawn so
/// they show their effect: a marker over a yellow stroke, a soft blurred dot, a grey mosaic.
struct ToolIcon: View {
    let tool: AnnotationTool

    var body: some View {
        switch tool {
        case .highlight:
            ZStack(alignment: .bottom) {
                Capsule()
                    .fill(Color(red: 1, green: 0.8, blue: 0).opacity(0.9))
                    .frame(width: 16, height: 4)
                    .offset(y: 1)
                Image(systemName: "highlighter")
                    .font(.system(size: 13, weight: .medium))
                    .offset(y: -3)
            }
            .frame(width: 18, height: 18)

        case .blur:
            ZStack {
                Circle().fill(.white.opacity(0.9)).frame(width: 11, height: 11).blur(radius: 2.5)
                Circle().strokeBorder(.white.opacity(0.35), lineWidth: 1).frame(width: 17, height: 17)
            }
            .frame(width: 18, height: 18)

        case .pixelate:
            Grid(horizontalSpacing: 1, verticalSpacing: 1) {
                ForEach(0..<3) { row in
                    GridRow {
                        ForEach(0..<3) { column in
                            Rectangle()
                                .fill(.white.opacity(Self.mosaic[row * 3 + column]))
                                .frame(width: 5, height: 5)
                        }
                    }
                }
            }
            .frame(width: 18, height: 18)

        default:
            Image(systemName: tool.systemImage)
                .font(.system(size: 14, weight: .medium))
        }
    }

    private static let mosaic: [Double] = [0.95, 0.45, 0.75, 0.35, 0.85, 0.5, 0.7, 0.4, 0.95]
}
