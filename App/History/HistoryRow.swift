import KropicCore
import SwiftUI

struct HistoryRow: View {
    let entry: HistoryEntry
    let isCopied: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: entry.text)
                .font(.kropicBody)
                .foregroundStyle(Color.textPrimary)
                .lineLimit(2)
            if let translation = entry.translation {
                Text(verbatim: translation)
                    .font(.kropicBody)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(2)
            }
            HStack {
                Text(verbatim: languages)
                Spacer()
                if isCopied {
                    Label("Copied", systemImage: "checkmark")
                        .foregroundStyle(Color.accent)
                } else {
                    Text(entry.date, format: .relative(presentation: .named))
                }
            }
            .font(.kropicCaption)
            .foregroundStyle(Color.textSecondary)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }

    private var languages: String {
        let names = [entry.sourceLanguage, entry.targetLanguage].compactMap { identifier in
            identifier.map { LanguageCatalog.displayName(Locale.Language(identifier: $0)) }
        }
        return names.joined(separator: " → ")
    }
}
