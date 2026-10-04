import SwiftUI

/// "TRANSLATION" with Copy, above the translation or a state message. A missing language
/// pack replaces the whole section with the download notice.
struct TranslationSection: View {
    let model: TranslationViewModel
    let isWaitingForText: Bool

    var body: some View {
        if !isWaitingForText, model.state == .needsDownload {
            StatusCard(
                systemImage: "arrow.down.to.line",
                title: String(localized: "\(model.pairName) language pack needed"),
                message: String(localized: "Translation runs on this Mac, so this language pair has to be downloaded once. The extracted text is ready to copy already.")
            ) {
                Button("Not Now", action: model.declineDownload)
                    .buttonStyle(SecondaryButtonStyle(textColor: .warningText, borderColor: .warningBorder))
                Button("Download", action: model.downloadLanguagePack)
                    .buttonStyle(PrimaryButtonStyle())
            }
        } else {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    SectionLabel(title: "Translation", tint: .accent)
                    Spacer()
                    if !isWaitingForText, let translated = model.translatedText {
                        CopyButton(text: translated)
                    }
                }
                .frame(height: 24)
                content
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if isWaitingForText {
            MutedBox(message: String(localized: "Translation starts automatically when the text is ready."))
        } else {
            switch model.state {
            case .idle:
                MutedBox(message: "")
            case .ready:
                MutedBox(message: "") {
                    Button("Translate", action: model.translateNow).buttonStyle(PrimaryButtonStyle())
                }
            case .translating:
                ProgressView()
                    .controlSize(.small)
                    .frame(maxWidth: .infinity, minHeight: Metrics.Field.minHeight)
                    .background(RoundedRectangle(cornerRadius: Metrics.Field.cornerRadius).fill(Color.translationBackground))
            case .translated(let translation):
                TranslationBox(text: translation)
            case .sameLanguage:
                MutedBox(message: String(localized: "Source and target are the same language."))
            case .needsDownload, .downloadDeclined:
                MutedBox(message: String(localized: "Translating \(model.pairName) needs a language pack that isn't downloaded yet.")) {
                    Button("Download…", action: model.downloadLanguagePack).buttonStyle(TextActionButtonStyle())
                }
            case .unsupported:
                MutedBox(message: unsupportedMessage)
            case .failed(let message):
                MutedBox(message: message) {
                    Button("Try Again", action: model.translateNow).buttonStyle(TextActionButtonStyle())
                }
            }
        }
    }

    private var unsupportedMessage: String {
        guard let source = model.source, let target = model.target else {
            return String(localized: "Translation between these languages isn't supported.")
        }
        return String(localized: "Translating from \(LanguageCatalog.displayName(source)) to \(LanguageCatalog.displayName(target)) isn't supported.")
    }
}
