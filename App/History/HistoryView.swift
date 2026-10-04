import KropicCore
import SwiftUI

/// The last results. Clicking an entry copies its extracted text. No artboard exists for this
/// window; it uses the result panel's tokens and components.
struct HistoryView: View {
    let model: HistoryViewModel
    let settings: AppSettings

    @State private var confirmingClear = false

    var body: some View {
        VStack(spacing: 0) {
            if model.entries.isEmpty {
                EmptyStateView(
                    systemImage: "clock",
                    title: String(localized: "No History"),
                    message: settings.saveHistory
                        ? String(localized: "Results you capture will appear here.")
                        : String(localized: "Saving history is turned off in Settings.")
                ) {
                    EmptyView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(model.entries) { entry in
                    HistoryRow(entry: entry, isCopied: model.copiedEntryID == entry.id)
                        .onTapGesture { model.copy(entry.text, from: entry) }
                        .contextMenu {
                            Button("Copy Text") { model.copy(entry.text, from: entry) }
                            if let translation = entry.translation {
                                Button("Copy Translation") { model.copy(translation, from: entry) }
                            }
                        }
                        .listRowSeparatorTint(Color.rowSeparator)
                }
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
            }

            footer
        }
        .frame(minWidth: 420, idealWidth: 480, minHeight: 360, idealHeight: 520)
        .background(Color.panelBackground)
        .task { await model.reload() }
        .confirmationDialog("Clear all history?", isPresented: $confirmingClear) {
            Button("Clear History", role: .destructive) {
                Task { try? await model.clear() }
            }
        } message: {
            Text("This removes all saved results. It can't be undone.")
        }
    }

    private var footer: some View {
        HStack(spacing: 8) {
            if let errorMessage = model.errorMessage {
                Text(verbatim: errorMessage).foregroundStyle(Color.danger)
            } else {
                Text("Click an entry to copy its text.").foregroundStyle(Color.textSecondary)
            }
            Spacer()
            Button("Clear History…") { confirmingClear = true }
                .buttonStyle(SecondaryButtonStyle(textColor: .danger))
                .disabled(model.entries.isEmpty)
        }
        .font(.kropicCaption)
        .padding(.horizontal, Metrics.ResultPanel.footerPadding)
        .frame(height: 48)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.panelSeparator).frame(height: 1)
        }
    }
}
