#if DEBUG
import SwiftUI

/// Every color token next to its name, plus a few native controls, to check the asset
/// catalog and both appearances at a glance.
struct TokenSwatchView: View {
    private let tokens: [(String, Color)] = [
        ("accent", .accent), ("accentFill", .accentFill),
        ("panelBackground", .panelBackground), ("settingsBackground", .settingsBackground),
        ("groupBackground", .groupBackground), ("surface (semantic)", .surface),
        ("textPrimary", .textPrimary), ("textSecondary", .textSecondary),
        ("panelSeparator (semantic)", .panelSeparator), ("rowSeparator", .rowSeparator),
        ("controlBorder", .controlBorder), ("chipBackground", .chipBackground),
        ("chipText", .chipText), ("translationBackground", .translationBackground),
        ("translationText", .translationText), ("skeleton", .skeleton),
        ("warningBackground", .warningBackground), ("warningBorder", .warningBorder),
        ("warningText", .warningText), ("danger", .danger),
        ("overlayDim", .overlayDim), ("overlayChrome", .overlayChrome),
    ]

    @State private var toggle = true
    @State private var mode = AppearanceMode.system
    @State private var text = "Text field"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tokens").font(.emptyStateTitle).foregroundStyle(Color.textPrimary)
            LazyVGrid(columns: [GridItem(.fixed(250)), GridItem(.fixed(250))], alignment: .leading, spacing: 8) {
                ForEach(tokens, id: \.0) { name, color in
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color)
                            .frame(width: 36, height: 22)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.panelSeparator))
                        Text(name).font(.kropicCaption).foregroundStyle(Color.textSecondary)
                    }
                }
            }
            Text("Native controls").font(.sectionLabel).tracking(Metrics.sectionLabelTracking)
                .textCase(.uppercase).foregroundStyle(Color.textSecondary)
            HStack(spacing: 12) {
                Toggle("Switch", isOn: $toggle).toggleStyle(.switch)
                Picker("Mode", selection: $mode) {
                    ForEach(AppearanceMode.allCases) { Text($0.rawValue.capitalized).tag($0) }
                }
                .pickerStyle(.segmented).frame(width: 200).labelsHidden()
                Button("Primary") {}.buttonStyle(.borderedProminent)
                TextField("Field", text: $text).frame(width: 120)
            }
        }
        .padding(20)
        .background(Color.panelBackground)
    }
}
#endif
