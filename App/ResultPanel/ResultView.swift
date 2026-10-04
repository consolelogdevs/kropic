import KeyboardShortcuts
import SwiftUI

/// The result panel: header, captured image on the left, text and translation on the right, footer.
/// 760 pt wide; at least 440 pt high and taller for long text.
struct ResultView: View {
    @Bindable var model: ResultViewModel
    let onCaptureAgain: () -> Void
    let onClose: () -> Void
    var onAnnotate: () -> Void = {}
    /// Reports the content's height so the panel can resize itself.
    var onHeightChange: (CGFloat) -> Void = { _ in }

    var body: some View {
        VStack(spacing: 0) {
            ResultHeader(
                sizeText: model.sizeText,
                showsCaptureAgain: model.state == .recognized,
                showsAnnotate: model.image != nil && model.state != .recognizing,
                onAnnotate: onAnnotate,
                onCaptureAgain: onCaptureAgain,
                onClose: onClose
            )
            HStack(alignment: .top, spacing: Metrics.ResultPanel.columnGap) {
                CapturedImageColumn(model: model)
                rightColumn
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .padding(Metrics.ResultPanel.contentPadding)
            .frame(maxHeight: .infinity, alignment: .top)
            PanelFooter(hint: footerHint, note: String(localized: "Apple Translation · on device"))
        }
        .frame(width: Metrics.ResultPanel.width)
        .frame(minHeight: Metrics.ResultPanel.designHeight)
        .background(Color.panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.ResultPanel.cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: Metrics.ResultPanel.cornerRadius).strokeBorder(Color.panelSeparator))
        .fixedSize(horizontal: false, vertical: true)
        .onGeometryChange(for: CGFloat.self, of: { $0.size.height }, action: onHeightChange)
        .frame(maxHeight: .infinity, alignment: .top)
        .modifier(TranslationHost(provider: model.translationProvider))
        .task {
            await model.translation.loadLanguages()
        }
    }

    @ViewBuilder
    private var rightColumn: some View {
        switch model.state {
        case .recognizing, .recognized:
            VStack(alignment: .leading, spacing: Metrics.ResultPanel.rightColumnGap) {
                ExtractedTextSection(model: model)
                LanguageBar(model: model.translation, canSwap: model.canSwapLanguages, onSwap: model.swapLanguages)
                TranslationSection(model: model.translation, isWaitingForText: model.state == .recognizing)
            }

        case .noText:
            EmptyStateView(
                systemImage: "text.magnifyingglass",
                title: String(localized: "No text found in this area"),
                message: String(localized: "The selection may contain a photo or very small text. Try selecting a slightly larger area.")
            ) {
                Button("Close", action: onClose).buttonStyle(SecondaryButtonStyle())
                Button("Capture Again", action: onCaptureAgain).buttonStyle(PrimaryButtonStyle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let message):
            EmptyStateView(
                systemImage: "exclamationmark.triangle",
                title: String(localized: "Something went wrong"),
                message: message
            ) {
                Button("Close", action: onClose).buttonStyle(SecondaryButtonStyle())
                Button("Capture Again", action: onCaptureAgain).buttonStyle(PrimaryButtonStyle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var footerHint: String {
        switch model.state {
        case .recognizing:
            return String(localized: "Esc to cancel")
        case .noText, .failed:
            let shortcut = KeyboardShortcuts.getShortcut(for: .captureText)?.description ?? ""
            return shortcut.isEmpty
                ? String(localized: "Esc to close")
                : String(localized: "Esc to close · \(shortcut) to capture again")
        case .recognized:
            return model.translation.translatedText == nil
                ? String(localized: "Esc to close · ⌘C copies the text")
                : String(localized: "Esc to close · ⌘⇧C copies the translation")
        }
    }
}
