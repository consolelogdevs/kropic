import SwiftUI

/// 32 × 32 icon-only button, e.g. capture again and close in the result panel header,
/// or the accent swap button between the language pickers.
struct IconButtonStyle: ButtonStyle {
    var tint: Color = .textSecondary

    func makeBody(configuration: Configuration) -> some View {
        IconButton(configuration: configuration, tint: tint)
    }
}

private struct IconButton: View {
    let configuration: ButtonStyleConfiguration
    let tint: Color

    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false

    var body: some View {
        configuration.label
            .labelStyle(.iconOnly)
            .font(.system(size: Metrics.ResultPanel.iconSize))
            .foregroundStyle(tint)
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
