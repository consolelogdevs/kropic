import SwiftUI

/// Grey box with a secondary message and an optional action, used for translation states
/// that have no translation to show.
struct MutedBox<Action: View>: View {
    let message: String
    @ViewBuilder var action: () -> Action

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !message.isEmpty {
                Text(verbatim: message)
                    .font(.kropicBody)
                    .lineSpacing(3)
                    .foregroundStyle(Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            action()
        }
        .padding(.horizontal, Metrics.Field.horizontalPadding)
        .padding(.vertical, Metrics.Field.verticalPadding)
        .frame(maxWidth: .infinity, minHeight: Metrics.Field.minHeight, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: Metrics.Field.cornerRadius).fill(Color.mutedBackground))
    }
}

extension MutedBox where Action == EmptyView {
    init(message: String) {
        self.init(message: message) { EmptyView() }
    }
}
