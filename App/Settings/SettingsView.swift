import KeyboardShortcuts
import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings
    let launchAtLogin: LaunchAtLogin
    let onClearHistory: () async throws -> Void

    @State private var languages: [Locale.Language] = []
    @State private var launchError: String?
    @State private var confirmingClear = false
    @State private var historyMessage: String?

    var body: some View {
        Form {
            Section("General") {
                KeyboardShortcuts.Recorder("Capture shortcut", name: .captureText)
                Toggle("Launch at login", isOn: launchAtLoginBinding)
                if launchAtLogin.requiresApproval {
                    HStack {
                        Text("Allow Kropic in System Settings to finish turning this on.")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Open Login Items") { launchAtLogin.openLoginItemsSettings() }
                    }
                }
                if let launchError {
                    Text(launchError).foregroundStyle(.red)
                }
            }

            Section("Translation") {
                Picker("Default target language", selection: $settings.defaultTargetLanguage) {
                    Text("Last used").tag(String?.none)
                    Divider()
                    ForEach(languages, id: \.self) { language in
                        Text(LanguageCatalog.displayName(language)).tag(Optional(language.minimalIdentifier))
                    }
                }
                Toggle("Translate automatically", isOn: $settings.translateAutomatically)
            }

            Section("Text") {
                Toggle("Copy extracted text automatically", isOn: $settings.copyTextAutomatically)
            }

            Section {
                Toggle("Save history", isOn: $settings.saveHistory)
                HStack {
                    if let historyMessage {
                        Text(historyMessage).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Clear History…", role: .destructive) { confirmingClear = true }
                }
            } header: {
                Text("History")
            } footer: {
                Text("The last 20 results, text only. Captured images are never saved.")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 460)
        .fixedSize(horizontal: false, vertical: true)
        .confirmationDialog("Clear all history?", isPresented: $confirmingClear) {
            Button("Clear History", role: .destructive) { clearHistory() }
        } message: {
            Text("This removes all saved results. It can't be undone.")
        }
        .task {
            languages = LanguageCatalog.sortedByName(await AppleTranslationProvider().supportedLanguages)
        }
        .onAppear { launchAtLogin.refresh() }
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding {
            launchAtLogin.isEnabled
        } set: { enabled in
            do {
                try launchAtLogin.setEnabled(enabled)
                launchError = nil
            } catch {
                launchError = error.localizedDescription
            }
        }
    }

    private func clearHistory() {
        Task {
            do {
                try await onClearHistory()
                historyMessage = "History cleared."
            } catch {
                historyMessage = error.localizedDescription
            }
        }
    }
}
