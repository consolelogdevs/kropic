import KropicCore
import SwiftUI

struct HistoryRow: View {
    let entry: HistoryEntry
    let isCopied: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.text)
                .lineLimit(2)
            if let translation = entry.translation {
                Text(translation)
                    .lineLimit(2)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text(languages)
                Spacer()
                if isCopied {
                    Label("Copied", systemImage: "checkmark")
                } else {
                    Text(entry.date, format: .relative(presentation: .named))
                }
            }
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    private var languages: String {
        let names = [entry.sourceLanguage, entry.targetLanguage].compactMap { identifier in
            identifier.map { LanguageCatalog.displayName(Locale.Language(identifier: $0)) }
        }
        return names.joined(separator: " → ")
    }
}
