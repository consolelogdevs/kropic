#if DEBUG
import KropicCore
import SwiftUI

/// The History window with sample entries, and empty.
@MainActor
enum HistoryPreview {
    static var filled: some View {
        let model = makeModel()
        model.setPreview(entries: [
            HistoryEntry(date: Date().addingTimeInterval(-120), text: "Opening hours have changed. From 1 November the library closes at 18:00 on weekdays and stays closed on Sundays.", translation: "Çalışma saatleri değişti. 1 Kasım'dan itibaren kütüphane hafta içi 18:00'de kapanıyor ve pazar günleri kapalı.", sourceLanguage: "en", targetLanguage: "tr"),
            HistoryEntry(date: Date().addingTimeInterval(-3_600), text: "営業時間が変更されました。", translation: nil, sourceLanguage: "ja", targetLanguage: nil),
            HistoryEntry(date: Date().addingTimeInterval(-90_000), text: "Members can now borrow up to eight books at a time.", translation: "Üyeler artık aynı anda sekiz kitaba kadar ödünç alabilir.", sourceLanguage: "en", targetLanguage: "tr"),
        ])
        return HistoryView(model: model, settings: settings).frame(width: 480, height: 420)
    }

    static var empty: some View {
        HistoryView(model: makeModel(), settings: settings).frame(width: 480, height: 420)
    }

    private static let settings = AppSettings(defaults: UserDefaults(suiteName: "KropicPreviews") ?? .standard)

    private static func makeModel() -> HistoryViewModel {
        HistoryViewModel(store: HistoryStore(fileURL: FileManager.default.temporaryDirectory.appending(path: "PreviewHistory.json")))
    }
}
#endif
