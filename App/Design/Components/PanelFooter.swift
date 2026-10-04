import SwiftUI

/// 36 pt bar at the bottom of the result panel: keyboard hints left, a note right.
struct PanelFooter: View {
    let hint: String
    let note: String

    var body: some View {
        HStack {
            Text(verbatim: hint)
            Spacer()
            Text(verbatim: note)
        }
        .font(.kropicCaption)
        .foregroundStyle(Color.textSecondary)
        .padding(.horizontal, Metrics.ResultPanel.footerPadding)
        .frame(height: Metrics.ResultPanel.footerHeight)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.panelSeparator).frame(height: 1)
        }
    }
}
