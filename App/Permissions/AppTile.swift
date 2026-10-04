import SwiftUI

/// 64 pt accent tile with the Kropic glyph in white, like the app icon.
struct AppTile: View {
    var body: some View {
        Image(.menuBarIcon)
            .renderingMode(.template)
            .resizable()
            .frame(width: 36, height: 36)
            .foregroundStyle(.white)
            .frame(width: 64, height: 64)
            .background(RoundedRectangle(cornerRadius: 15).fill(Color.accentFill))
            .accessibilityHidden(true)
    }
}
