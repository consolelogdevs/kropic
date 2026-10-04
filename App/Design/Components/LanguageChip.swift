import SwiftUI

/// Pill next to a section label, e.g. "English · detected".
struct LanguageChip: View {
    let text: String

    var body: some View {
        Text(verbatim: text)
            .font(.kropicCaption)
            .foregroundStyle(Color.chipText)
            .padding(.horizontal, 8)
            .frame(height: 20)
            .background(Capsule().fill(Color.chipBackground))
    }
}
