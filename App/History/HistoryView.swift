import KropicCore
import SwiftUI

/// The last results. Clicking an entry copies its extracted text.
struct HistoryView: View {
    let model: HistoryViewModel
    let settings: AppSettings

    @State private var confirmingClear = false

    var body: some View {
        VStack(spacing: 0) {
            if model.entries.isEmpty {
                ContentUnavailableView(
                    "No History",
                    systemImage: "clock",
                    description: Text(settings.saveHistory
                        ? "Results you capture will appear here."
                        : "Saving history is turned off in Settings.")
                )
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
                }
            }

            Divider()
            HStack {
                Text("Click an entry to copy its text.")
                    .foregroundStyle(.secondary)
                if let errorMessage = model.errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }
                Spacer()
                Button("Clear History…", role: .destructive) { confirmingClear = true }
                    .disabled(model.entries.isEmpty)
            }
            .font(.callout)
            .padding(10)
        }
        .frame(minWidth: 420, idealWidth: 480, minHeight: 360, idealHeight: 520)
        .task { await model.reload() }
        .confirmationDialog("Clear all history?", isPresented: $confirmingClear) {
            Button("Clear History", role: .destructive) {
                Task { try? await model.clear() }
            }
        } message: {
            Text("This removes all saved results. It can't be undone.")
        }
    }
}
