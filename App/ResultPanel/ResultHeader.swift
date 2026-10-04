import SwiftUI

/// 44 pt header: crop glyph, app name and selection size; capture again and close on the right.
/// Dragging the header moves the panel.
struct ResultHeader: View {
    let sizeText: String
    let showsCaptureAgain: Bool
    let onCaptureAgain: () -> Void
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "crop")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.accent)
            Text(verbatim: "Kropic")
                .fontWeight(.semibold)
                .foregroundStyle(Color.textPrimary)
            Text(verbatim: sizeText)
                .foregroundStyle(Color.textSecondary)
            Spacer()
            HStack(spacing: 2) {
                if showsCaptureAgain {
                    Button("Capture Again", systemImage: "crop", action: onCaptureAgain)
                        .buttonStyle(IconButtonStyle())
                        .help("Capture Again")
                }
                Button("Close", systemImage: "xmark", action: onClose)
                    .buttonStyle(IconButtonStyle())
                    .help("Close (Esc)")
            }
        }
        .font(.kropicBody)
        .padding(.leading, Metrics.ResultPanel.headerLeadingPadding)
        .padding(.trailing, Metrics.ResultPanel.headerTrailingPadding)
        .frame(height: Metrics.ResultPanel.headerHeight)
        .contentShape(Rectangle())
        .gesture(WindowDragGesture())
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.panelSeparator).frame(height: 1)
        }
    }
}
