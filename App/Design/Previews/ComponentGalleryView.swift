#if DEBUG
import SwiftUI

/// Every shared component with sample content, for comparison with the spec.
struct ComponentGalleryView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 8) {
                SectionLabel(title: "Extracted text")
                LanguageChip(text: "English · detected")
                Spacer()
                Button("Copy", systemImage: "doc.on.doc") {}
                    .buttonStyle(TextActionButtonStyle())
            }
            SectionLabel(title: "Translation", tint: .accent)

            Text(verbatim: "Opening hours have changed. From 1 November the library closes at 18:00 on weekdays.")
                .font(.kropicBody)
                .foregroundStyle(Color.textPrimary)
                .fieldBackground()

            HStack(spacing: 8) {
                Button("Close") {}.buttonStyle(SecondaryButtonStyle())
                Button("Capture Again") {}.buttonStyle(PrimaryButtonStyle())
                Button("Capture again", systemImage: "crop") {}.buttonStyle(IconButtonStyle())
                Button("Close", systemImage: "xmark") {}.buttonStyle(IconButtonStyle())
                Button("Disabled") {}.buttonStyle(PrimaryButtonStyle()).disabled(true)
            }

            StatusCard(
                systemImage: "arrow.down.to.line",
                title: "Japanese → Turkish language pack needed",
                message: "Translation runs on this Mac, so this language pair has to be downloaded once. The extracted text is ready to copy already."
            ) {
                Button("Not Now") {}.buttonStyle(SecondaryButtonStyle(textColor: .warningText, borderColor: .warningBorder))
                Button("Download") {}.buttonStyle(PrimaryButtonStyle())
            }

            EmptyStateView(
                systemImage: "text.magnifyingglass",
                title: "No text found in this area",
                message: "The selection may contain a photo or very small text. Try selecting a slightly larger area."
            ) {
                Button("Close") {}.buttonStyle(SecondaryButtonStyle())
                Button("Capture Again") {}.buttonStyle(PrimaryButtonStyle())
            }
            .frame(maxWidth: .infinity)

            PanelFooter(hint: "Esc to close · ⌘⇧C copies the translation", note: "Apple Translation · on device")
                .padding(.horizontal, -20)
        }
        .padding(20)
        .frame(width: 456)
        .background(Color.panelBackground)
    }
}
#endif
