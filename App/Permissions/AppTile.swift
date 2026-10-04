import SwiftUI

/// 64 pt accent tile with the crop glyph, like the app icon.
struct AppTile: View {
    var body: some View {
        Image(systemName: "crop")
            .font(.system(size: 28, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 64, height: 64)
            .background(RoundedRectangle(cornerRadius: 15).fill(Color.accentFill))
            .accessibilityHidden(true)
    }
}
