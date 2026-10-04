import SwiftUI

/// A bordered text editor that grows with its text from 76 pt up to `maxHeight`, then scrolls.
struct GrowingTextEditor: View {
    @Binding var text: String
    var maxHeight: CGFloat = 200

    /// TextEditor insets each line by 5 pt; the field padding makes up the rest of the spec's 12.
    private static let editorInset: CGFloat = 5

    var body: some View {
        // An invisible copy of the text sets the height; the editor is laid over it.
        // `fixedSize` keeps that height, so spare panel height stays below the sections.
        Text(verbatim: sizingText)
            .font(.kropicBody)
            .padding(.horizontal, Self.editorInset)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(0)
            .accessibilityHidden(true)
            .frame(minHeight: Metrics.Field.minHeight - 2 * Metrics.Field.verticalPadding, maxHeight: maxHeight, alignment: .top)
            .fixedSize(horizontal: false, vertical: true)
            .overlay {
                TextEditor(text: $text)
                    .font(.kropicBody)
                    .foregroundStyle(Color.textPrimary)
                    .scrollContentBackground(.hidden)
            }
            .fieldBackground(horizontalPadding: Metrics.Field.horizontalPadding - Self.editorInset)
    }

    /// Text ignores a trailing newline when measuring, the editor does not.
    private var sizingText: String {
        text.isEmpty || text.hasSuffix("\n") ? text + " " : text
    }
}
