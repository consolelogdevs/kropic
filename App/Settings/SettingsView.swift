import KeyboardShortcuts
import SwiftUI

/// Native grouped form in the spec's order: Capture, Translation, General, then a privacy note.
struct SettingsView: View {
    @Bindable var settings: AppSettings
    let launchAtLogin: LaunchAtLogin
    let onClearHistory: () async throws -> Void

    @State private var languages: [Locale.Language] = []
    @State private var launchError: String?
    @State private var confirmingClear = false
    @State private var historyCleared = false
    @State private var historyError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Form {
                Section("Capture") {
                    KeyboardShortcuts.Recorder("Capture shortcut", name: .captureText)
                    Toggle(isOn: $settings.translateAutomatically) {
                        SettingLabel(title: "Translate automatically", subtitle: "When source and target languages differ")
                    }
                    Toggle("Copy extracted text to the clipboard", isOn: $settings.copyTextAutomatically)
                }

                Section("Translation") {
                    Picker("Default target language", selection: $settings.defaultTargetLanguage) {
                        Text("Last Used").tag(String?.none)
                        Divider()
                        ForEach(languages, id: \.self) { language in
                            Text(verbatim: LanguageCatalog.displayName(language)).tag(Optional(language.minimalIdentifier))
                        }
                    }
                }

                Section("General") {
                    Picker("Appearance", selection: $settings.appearance) {
                        Text("System").tag(AppearanceMode.system)
                        Text("Light").tag(AppearanceMode.light)
                        Text("Dark").tag(AppearanceMode.dark)
                    }
                    .pickerStyle(.segmented)

                    Toggle("Launch at login", isOn: launchAtLoginBinding)
                    if launchAtLogin.requiresApproval {
                        HStack {
                            Text("Allow Kropic in System Settings to finish turning this on.")
                                .font(.kropicCaption)
                                .foregroundStyle(Color.textSecondary)
                            Spacer()
                            Button("Open Login Items") { launchAtLogin.openLoginItemsSettings() }
                        }
                    }
                    if let launchError {
                        Text(verbatim: launchError).font(.kropicCaption).foregroundStyle(Color.danger)
                    }

                    Toggle(isOn: $settings.saveHistory) {
                        SettingLabel(title: "Save history", subtitle: "Last 20 results, text only")
                    }
                    HStack {
                        if let historyError {
                            Text(verbatim: historyError).font(.kropicCaption).foregroundStyle(Color.danger)
                        }
                        Spacer()
                        Button(historyCleared ? "History Cleared" : "Clear History…") { confirmingClear = true }
                            .buttonStyle(SecondaryButtonStyle(textColor: .danger))
                            .disabled(historyCleared)
                    }
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .scrollDisabled(true)

            Text("Captured images are never saved to disk. History keeps only the extracted text and the translation.")
                .font(.kropicCaption)
                .foregroundStyle(Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
        }
        .frame(width: 600)
        .fixedSize(horizontal: false, vertical: true)
        .background(Color.settingsBackground)
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
                historyError = nil
                historyCleared = true
                try? await Task.sleep(for: .seconds(2))
                historyCleared = false
            } catch {
                historyError = error.localizedDescription
            }
        }
    }
}
