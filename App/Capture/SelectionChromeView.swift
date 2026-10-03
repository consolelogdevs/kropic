import KropicCore
import SwiftUI

/// Draws the dim layer with a cut-out, the selection border, handles and the size label.
struct SelectionChromeView: View {
    let selection: CGRect?
    let showsHandles: Bool

    private static let handleSize: CGFloat = 8
    private static let labelHeight: CGFloat = 18

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                dimLayer(size: geometry.size)

                if let selection {
                    Rectangle()
                        .stroke(Color.white, lineWidth: 1)
                        .frame(width: selection.width, height: selection.height)
                        .position(x: selection.midX, y: selection.midY)

                    if showsHandles {
                        ForEach(SelectionHandle.allCases, id: \.self) { handle in
                            let point = SelectionGeometry.point(of: handle, in: selection)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.4), radius: 1)
                                .frame(width: Self.handleSize, height: Self.handleSize)
                                .position(point)
                        }
                    }

                    sizeLabel(for: selection)
                }
            }
        }
    }

    private func dimLayer(size: CGSize) -> some View {
        Path { path in
            path.addRect(CGRect(origin: .zero, size: size))
            if let selection {
                path.addRect(selection)
            }
        }
        .fill(Color.black.opacity(0.35), style: FillStyle(eoFill: true))
    }

    private func sizeLabel(for selection: CGRect) -> some View {
        // Above the top-left corner, or just inside it when the selection touches the top edge.
        let y = selection.minY >= Self.labelHeight + 4 ? selection.minY - Self.labelHeight - 4 : selection.minY + 4
        return Text("\(Int(selection.width.rounded())) × \(Int(selection.height.rounded()))")
            .font(.system(size: 11, weight: .medium).monospacedDigit())
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .frame(height: Self.labelHeight)
            .background(Capsule().fill(Color.black.opacity(0.7)))
            .fixedSize()
            .offset(x: selection.minX, y: y)
    }
}
