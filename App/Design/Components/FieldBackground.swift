import SwiftUI

extension View {
    /// The bordered box behind text areas: surface fill, 1 pt control border, radius 8,
    /// padding 10 × 12, at least 76 pt high.
    func fieldBackground(minHeight: CGFloat = Metrics.Field.minHeight) -> some View {
        padding(.horizontal, Metrics.Field.horizontalPadding)
            .padding(.vertical, Metrics.Field.verticalPadding)
            .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
            .background(RoundedRectangle(cornerRadius: Metrics.Field.cornerRadius).fill(Color.surface))
            .overlay(RoundedRectangle(cornerRadius: Metrics.Field.cornerRadius).strokeBorder(Color.controlBorder))
    }
}
