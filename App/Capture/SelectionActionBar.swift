import SwiftUI

/// Dark bar under the selection with cancel (×) and confirm (✓).
struct SelectionActionBar: View {
    let onCancel: () -> Void
    let onConfirm: () -> Void

    private static let buttonSize = Metrics.Overlay.barButtonSize

    var body: some View {
        HStack(spacing: 4) {
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: Self.buttonSize, height: Self.buttonSize)
                    .contentShape(Rectangle())
            }
            .help("Cancel (Esc)")

            Button(action: onConfirm) {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: Self.buttonSize, height: Self.buttonSize)
                    .background(RoundedRectangle(cornerRadius: 7).fill(Color.accentFill))
            }
            .help("Capture (Return)")
        }
        .buttonStyle(.plain)
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.overlayChrome))
    }
}
