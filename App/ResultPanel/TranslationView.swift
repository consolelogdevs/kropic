import SwiftUI

/// Language pickers and the translation output below the extracted text.
struct TranslationView: View {
    @Bindable var model: TranslationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            languageBar
            output
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(RoundedRectangle(cornerRadius: 6).fill(Color(nsColor: .controlBackgroundColor)))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(.separator))
        }
    }

    private var languageBar: some View {
        HStack(spacing: 6) {
            Picker("From", selection: $model.sourceSelection) {
                Text(automaticLabel).tag(TranslationViewModel.SourceSelection.automatic)
                Divider()
                ForEach(model.languages, id: \.self) { language in
                    Text(LanguageCatalog.displayName(language)).tag(TranslationViewModel.SourceSelection.language(language))
                }
            }
            Image(systemName: "arrow.right")
                .foregroundStyle(.secondary)
            Picker("To", selection: $model.target) {
                ForEach(model.languages, id: \.self) { language in
                    Text(LanguageCatalog.displayName(language)).tag(Optional(language))
                }
            }
        }
        .labelsHidden()
    }

    private var automaticLabel: String {
        guard let detected = model.detectedLanguage else { return String(localized: "Detect Language") }
        return String(localized: "Detected: \(LanguageCatalog.displayName(detected))")
    }

    @ViewBuilder
    private var output: some View {
        switch model.state {
        case .idle:
            EmptyView()

        case .ready:
            Button("Translate", action: model.translateNow)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .translating:
            ProgressView()
                .controlSize(.small)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .translated(let translation):
            VStack(alignment: .trailing, spacing: 6) {
                ScrollView {
                    Text(translation)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                }
                CopyButton(text: translation)
                    .padding([.trailing, .bottom], 6)
            }

        case .sameLanguage:
            note(String(localized: "Source and target are the same language."))

        case .unsupported:
            note(unsupportedMessage)

        case .needsDownload:
            note(String(localized: "Translating needs a language pack that isn't downloaded yet. The extracted text above is still available.")) {
                Button("Download…", action: model.translateNow)
            }

        case .failed(let message):
            note(message) {
                Button("Try Again", action: model.translateNow)
            }
        }
    }

    private var unsupportedMessage: String {
        guard let source = model.source, let target = model.target else {
            return String(localized: "Translation between these languages isn't supported.")
        }
        return String(localized: "Translating from \(LanguageCatalog.displayName(source)) to \(LanguageCatalog.displayName(target)) isn't supported.")
    }

    private func note(_ text: String, @ViewBuilder action: () -> some View = { EmptyView() }) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(text)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            action()
        }
        .padding(8)
    }
}
