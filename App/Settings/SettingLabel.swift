import SwiftUI

/// A settings row title with a smaller secondary line underneath.
struct SettingLabel: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
            Text(subtitle)
                .font(.kropicCaption)
                .foregroundStyle(Color.textSecondary)
        }
    }
}
