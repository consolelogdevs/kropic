import SwiftUI

/// 32 × 32 icon-only button for the result panel header (capture again, close).
struct IconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        IconButton(configuration: configuration)
    }
}

private struct IconButton: View {
    let configuration: ButtonStyleConfiguration

    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false

    var body: some View {
        configuration.label
            .labelStyle(.iconOnly)
            .font(.system(size: Metrics.ResultPanel.iconSize))
            .foregroundStyle(Color.textSecondary)
            .frame(width: Metrics.ResultPanel.iconButtonSize, height: Metrics.ResultPanel.iconButtonSize)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.textSecondary.opacity(isHovering && isEnabled ? 0.12 : 0))
            )
            .contentShape(Rectangle())
            .opacity(isEnabled ? (configuration.isPressed ? 0.6 : 1) : 0.4)
            .onHover { isHovering = $0 }
    }
}
