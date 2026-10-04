import SwiftUI

/// The translated text on the blue translation background. Selectable; scrolls when long.
struct TranslationBox: View {
    let text: String
    var maxHeight: CGFloat = 200

    var body: some View {
        ScrollView {
            Text(verbatim: text)
                .font(.kropicBody)
                .lineSpacing(3)
                .foregroundStyle(Color.translationText)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Metrics.Field.horizontalPadding)
                .padding(.vertical, Metrics.Field.verticalPadding)
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(minHeight: Metrics.Field.minHeight, maxHeight: maxHeight)
        .fixedSize(horizontal: false, vertical: true)
        .background(RoundedRectangle(cornerRadius: Metrics.Field.cornerRadius).fill(Color.translationBackground))
    }
}
