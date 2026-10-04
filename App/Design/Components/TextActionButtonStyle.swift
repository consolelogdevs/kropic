import SwiftUI

/// Borderless icon-and-label button used in section headers, e.g. "Copy".
struct TextActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        TextActionButton(configuration: configuration)
    }
}

private struct TextActionButton: View {
    let configuration: ButtonStyleConfiguration

    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovering = false

    var body: some View {
        configuration.label
            .labelStyle(TightLabelStyle())
            .font(.smallButton)
            .foregroundStyle(Color.textSecondary)
            .padding(.horizontal, 8)
            .frame(height: 24)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.textSecondary.opacity(isHovering && isEnabled ? 0.12 : 0))
            )
            .contentShape(Rectangle())
            .opacity(isEnabled ? (configuration.isPressed ? 0.6 : 1) : 0.4)
            .onHover { isHovering = $0 }
    }
}

/// Icon and title with the spec's 5 pt gap.
private struct TightLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 5) {
            configuration.icon
                .font(.system(size: 11))
            configuration.title
        }
    }
}
