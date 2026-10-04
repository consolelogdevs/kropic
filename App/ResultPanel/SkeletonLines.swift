import SwiftUI

/// Three grey bars in the text field while OCR runs.
struct SkeletonLines: View {
    private static let widths: [CGFloat] = [0.92, 1, 0.56]

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Self.widths, id: \.self) { fraction in
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.skeleton)
                        .frame(width: geometry.size.width * fraction, height: 9)
                }
            }
        }
        .frame(height: 47)
        .padding(.horizontal, Metrics.Field.horizontalPadding)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: Metrics.Field.cornerRadius).fill(Color.surface))
        .overlay(RoundedRectangle(cornerRadius: Metrics.Field.cornerRadius).strokeBorder(Color.controlBorder))
        .accessibilityLabel("Extracting text")
    }
}
