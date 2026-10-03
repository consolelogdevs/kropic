import SwiftUI

struct ResultView: View {
    @Bindable var model: ResultViewModel
    let onRetry: () -> Void

    private static let textColumnWidth: CGFloat = 320
    private static let minimumHeight: CGFloat = 200

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            if let image = model.image {
                let size = model.imageDisplaySize
                Image(decorative: image, scale: model.scale)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: size.width, height: size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.separator))
            }

            textColumn
                .frame(width: Self.textColumnWidth, height: max(model.imageDisplaySize.height, Self.minimumHeight))
        }
        .padding(16)
    }

    @ViewBuilder
    private var textColumn: some View {
        switch model.state {
        case .recognizing:
            VStack(spacing: 8) {
                ProgressView()
                    .controlSize(.small)
                Text("Recognizing text…")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .recognized:
            VStack(alignment: .trailing, spacing: 8) {
                TextEditor(text: $model.text)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .padding(6)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color(nsColor: .textBackgroundColor)))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(.separator))

                Button(model.didCopy ? "Copied" : "Copy", systemImage: model.didCopy ? "checkmark" : "doc.on.doc") {
                    model.copyText()
                }
            }

        case .noText:
            message("No text found in the selected area", systemImage: "text.magnifyingglass")

        case .failed(let text):
            message(text, systemImage: "exclamationmark.triangle")
        }
    }

    private func message(_ text: String, systemImage: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.secondary)
            Text(text)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Button("Try Again", action: onRetry)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
