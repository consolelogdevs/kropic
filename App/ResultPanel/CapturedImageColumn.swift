import SwiftUI

/// Left column: "CAPTURED AREA", the image in its real colors, and its size caption.
struct CapturedImageColumn: View {
    let model: ResultViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(title: "Captured area")
            image
            Text(verbatim: model.imageCaption)
                .font(.kropicCaption)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(width: Metrics.ResultPanel.leftColumnWidth, alignment: .leading)
    }

    @ViewBuilder
    private var image: some View {
        let shape = RoundedRectangle(cornerRadius: Metrics.Field.cornerRadius)
        if let image = model.image {
            let size = model.imageDisplaySize
            Image(decorative: image, scale: model.scale)
                .resizable()
                .interpolation(.high)
                .frame(width: size.width, height: size.height)
                .clipShape(shape)
                .overlay(shape.strokeBorder(Color.controlBorder))
        } else {
            Image(systemName: "photo")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(shape.fill(Color.skeleton))
                .overlay(shape.strokeBorder(Color.controlBorder))
        }
    }
}
