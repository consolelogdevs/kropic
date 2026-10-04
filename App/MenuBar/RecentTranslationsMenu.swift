import KropicCore
import SwiftUI

/// "Recent Translations" submenu: the last few results (choosing one copies its text) and
/// "Show All…" for the History window.
struct RecentTranslationsMenu: View {
    static let count = 5
    private static let titleLength = 40

    let history: HistoryViewModel
    let onShowAll: () -> Void

    var body: some View {
        Menu("Recent Translations") {
            let recent = history.entries.prefix(Self.count)
            if recent.isEmpty {
                Text("No Recent Translations")
            } else {
                ForEach(recent) { entry in
                    Button(title(for: entry)) {
                        history.copy(entry.text, from: entry)
                    }
                }
            }
            Divider()
            Button("Show All…", action: onShowAll)
        }
    }

    /// The first line of the text, shortened for the menu.
    private func title(for entry: HistoryEntry) -> String {
        let firstLine = entry.text.split(whereSeparator: \.isNewline).first.map(String.init) ?? entry.text
        guard firstLine.count > Self.titleLength else { return firstLine }
        return String(firstLine.prefix(Self.titleLength)).trimmingCharacters(in: .whitespaces) + "…"
    }
}
