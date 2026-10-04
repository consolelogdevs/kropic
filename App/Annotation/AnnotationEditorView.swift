import SwiftUI

/// The annotation window: toolbar, the image to draw on, and copy and share actions.
struct AnnotationEditorView: View {
    @Bindable var model: AnnotationEditorViewModel

    var body: some View {
        VStack(spacing: 0) {
            AnnotationToolbar(model: model)

            AnnotationCanvas(model: model)
                .padding(Metrics.ResultPanel.contentPadding)
                .frame(minWidth: 480)

            HStack(spacing: 8) {
                Text("Annotations stay on this Mac until you copy or share the image.")
                    .font(.kropicCaption)
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                Button(model.didCopy ? "Copied" : "Copy Image", action: model.copyImage)
                    .buttonStyle(SecondaryButtonStyle())
                ShareLink(
                    item: model.shareImage,
                    preview: SharePreview(Text("Kropic Capture"), image: model.shareImage)
                ) {
                    Text("Share…")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal, Metrics.ResultPanel.footerPadding)
            .frame(height: 52)
            .overlay(alignment: .top) {
                Rectangle().fill(Color.panelSeparator).frame(height: 1)
            }
        }
        .background(Color.panelBackground)
        .fixedSize()
    }
}
