import SwiftUI

/// Source picker, swap button, target picker. Native pop-up buttons (design/README.md).
struct LanguageBar: View {
    @Bindable var model: TranslationViewModel
    let canSwap: Bool
    let onSwap: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Picker("From", selection: $model.sourceSelection) {
                Text(verbatim: automaticTitle).tag(TranslationViewModel.SourceSelection.automatic)
                Divider()
                ForEach(model.languages, id: \.self) { language in
                    Text(verbatim: LanguageCatalog.displayName(language))
                        .tag(TranslationViewModel.SourceSelection.language(language))
                }
            }
            .frame(maxWidth: .infinity)

            Button("Swap Languages", systemImage: "arrow.left.arrow.right", action: onSwap)
                .buttonStyle(IconButtonStyle(tint: .accent))
                .disabled(!canSwap)
                .help("Swap Languages")

            Picker("To", selection: $model.target) {
                ForEach(model.languages, id: \.self) { language in
                    Text(verbatim: LanguageCatalog.displayName(language)).tag(Optional(language))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .labelsHidden()
        .controlSize(.large)
        .flexibleButtonSizing()
    }

    /// The automatic entry shows the detected language, like the spec's picker.
    private var automaticTitle: String {
        model.detectedLanguage.map(LanguageCatalog.displayName) ?? String(localized: "Detect Automatically")
    }
}
