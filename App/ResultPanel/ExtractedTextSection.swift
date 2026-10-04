import SwiftUI

/// "EXTRACTED TEXT" with the detected language chip and Copy, above the editable text.
/// While OCR runs it shows a spinner and placeholder bars instead.
struct ExtractedTextSection: View {
    @Bindable var model: ResultViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                SectionLabel(title: "Extracted text")
                if model.state == .recognized, let chip = model.translation.detectedChipText {
                    LanguageChip(text: chip)
                }
                Spacer()
                if model.state == .recognizing {
                    HStack(spacing: 6) {
                        ProgressView().controlSize(.mini)
                        Text("Extracting text…")
                    }
                    .font(.smallButton)
                    .foregroundStyle(Color.textSecondary)
                } else {
                    CopyButton(text: model.text)
                }
            }
            .frame(height: 24)

            if model.state == .recognizing {
                SkeletonLines()
            } else {
                GrowingTextEditor(text: $model.text)
            }
        }
    }
}
