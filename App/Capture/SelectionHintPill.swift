import SwiftUI

/// Gesture hints at the top of the screen, shown during the first few uses.
struct SelectionHintPill: View {
    var body: some View {
        HStack(spacing: 10) {
            Text("Drag to select")
            separator
            Text("Drag edges to resize")
            separator
            Text("Enter to confirm")
            separator
            Text("Esc to cancel")
        }
        .font(.kropicBody.weight(.medium))
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .frame(height: Metrics.Overlay.hintPillHeight)
        .background(Capsule().fill(Color.overlayChrome))
        .fixedSize()
    }

    private var separator: some View {
        Text(verbatim: "·").foregroundStyle(.white.opacity(0.5))
    }
}
