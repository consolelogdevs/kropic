import SwiftUI

struct ResultView: View {
    let model: ResultViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            imageArea
                .frame(minWidth: 120, minHeight: 80)

            // TODO(Phase 3): extracted text goes here.
            Text("Text recognition arrives in Phase 3.")
                .foregroundStyle(.secondary)
                .frame(width: 220, alignment: .leading)
        }
        .padding(16)
    }

    @ViewBuilder
    private var imageArea: some View {
        switch model.content {
        case .image(let image, let scale):
            let size = model.imageDisplaySize
            Image(decorative: image, scale: scale)
                .resizable()
                .interpolation(.high)
                .frame(width: size.width, height: size.height)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(.separator))
        case .failure(let message):
            Label(message, systemImage: "exclamationmark.triangle")
                .foregroundStyle(.secondary)
                .frame(width: 240, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
