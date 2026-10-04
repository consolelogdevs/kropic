import KropicCore
import SwiftUI

/// Draws the dim layer with a cut-out, the selection outline, handles and the size label.
struct SelectionChromeView: View {
    let selection: CGRect?
    let showsHandles: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                dimLayer(size: geometry.size)

                if let selection {
                    Rectangle()
                        .stroke(Color.white, lineWidth: Metrics.Overlay.outlineWidth)
                        .frame(width: selection.width, height: selection.height)
                        .position(x: selection.midX, y: selection.midY)

                    if showsHandles {
                        ForEach(SelectionHandle.allCases, id: \.self) { handle in
                            handleView.position(SelectionGeometry.point(of: handle, in: selection))
                        }
                    }

                    sizeLabel(for: selection)
                }
            }
        }
    }

    private var handleView: some View {
        let shape = RoundedRectangle(cornerRadius: Metrics.Overlay.handleCornerRadius)
        return shape
            .fill(Color.white)
            .overlay(shape.strokeBorder(Color.accent, lineWidth: 1))
            .frame(width: Metrics.Overlay.handleSize, height: Metrics.Overlay.handleSize)
    }

    private func dimLayer(size: CGSize) -> some View {
        Path { path in
            path.addRect(CGRect(origin: .zero, size: size))
            if let selection {
                path.addRect(selection)
            }
        }
        .fill(Color.overlayDim, style: FillStyle(eoFill: true))
    }

    private func sizeLabel(for selection: CGRect) -> some View {
        let height = Metrics.Overlay.sizeLabelHeight
        let gap = Metrics.Overlay.sizeLabelGap
        // Above the top-left corner, or just inside it when the selection touches the top edge.
        let y = selection.minY >= height + gap ? selection.minY - height - gap : selection.minY + gap
        return Text(verbatim: "\(Int(selection.width.rounded())) × \(Int(selection.height.rounded()))")
            .font(.kropicCaption.monospacedDigit())
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .frame(height: height)
            .background(RoundedRectangle(cornerRadius: Metrics.Overlay.sizeLabelCornerRadius).fill(Color.overlayChrome))
            .fixedSize()
            .offset(x: selection.minX - 2, y: y)
    }
}
