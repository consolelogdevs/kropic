import SwiftUI

/// Hints at the top of the screen. With a tool selected it explains that tool.
struct SelectionHintPill: View {
    var tool: AnnotationTool?
    var hasSelection = false

    var body: some View {
        HStack(spacing: 10) {
            if let tool {
                Text(verbatim: tool.hint)
                separator
                Text("V to move marks")
            } else if hasSelection {
                Text("Drag a mark to move it")
                separator
                Text("Delete removes it")
                separator
                Text("Pick a tool to annotate")
            } else {
                Text("Drag to select")
                separator
                Text("Pick a tool to annotate")
            }
            separator
            Text("Enter to translate")
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
