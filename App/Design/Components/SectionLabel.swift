import SwiftUI

/// Small uppercase label above a section, e.g. "CAPTURED AREA". Secondary by default; the
/// translation section uses the accent.
struct SectionLabel: View {
    let title: LocalizedStringKey
    var tint: Color = .textSecondary

    var body: some View {
        Text(title)
            .font(.sectionLabel)
            .tracking(Metrics.sectionLabelTracking)
            .textCase(.uppercase)
            .foregroundStyle(tint)
    }
}
