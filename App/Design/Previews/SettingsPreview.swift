#if DEBUG
import SwiftUI

struct SettingsPreview: View {
    var body: some View {
        SettingsView(
            settings: AppSettings(defaults: UserDefaults(suiteName: "KropicPreviews") ?? .standard),
            launchAtLogin: LaunchAtLogin(),
            onClearHistory: {}
        )
    }
}
#endif
