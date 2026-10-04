import SwiftUI

/// Bordered button on a surface, e.g. "Close" and "Not Now". 28 pt high. `tint` recolors
/// the text and border, for buttons inside a status card.
struct SecondaryButtonStyle: ButtonStyle {
    var textColor: Color = .textPrimary
    var borderColor: Color = .controlBorder

    func makeBody(configuration: Configuration) -> some View {
        SecondaryButton(configuration: configuration, textColor: textColor, borderColor: borderColor)
    }
}

private struct SecondaryButton: View {
    let configuration: ButtonStyleConfiguration
    let textColor: Color
    let borderColor: Color

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        configuration.label
            .font(.kropicBody)
            .foregroundStyle(textColor)
            .padding(.horizontal, 14)
            .frame(height: 28)
            .background(RoundedRectangle(cornerRadius: 6).fill(Color.surface))
            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(borderColor))
            .brightness(configuration.isPressed ? -0.05 : 0)
            .opacity(isEnabled ? 1 : 0.4)
    }
}
