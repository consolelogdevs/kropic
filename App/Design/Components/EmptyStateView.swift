import SwiftUI

/// Centered icon badge, title, message and actions, e.g. "No text found".
struct EmptyStateView<Actions: View>: View {
    let systemImage: String
    let title: String
    let message: String
    @ViewBuilder let actions: () -> Actions

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 18))
                .foregroundStyle(Color.textSecondary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.chipBackground))
            Text(verbatim: title)
                .font(.emptyStateTitle)
                .foregroundStyle(Color.textPrimary)
            Text(verbatim: message)
                .font(.kropicBody)
                .lineSpacing(3)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 340)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 8) {
                actions()
            }
            .padding(.top, 6)
        }
        .padding(.horizontal, 24)
    }
}
