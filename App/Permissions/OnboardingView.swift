import SwiftUI

/// Screen Recording permission window: app tile, explanation, three steps and actions.
struct OnboardingView: View {
    let permissions: PermissionService
    let onLater: () -> Void

    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 12) {
            AppTile()

            Text("Allow Kropic to see your screen")
                .font(.onboardingTitle)
                .foregroundStyle(Color.textPrimary)
                .padding(.top, 4)

            Text("Kropic needs to see the screen to read the text in the area you select. Images are processed in memory only, never saved and never sent anywhere.")
                .font(.kropicBody)
                .lineSpacing(4)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)
                .fixedSize(horizontal: false, vertical: true)

            OnboardingSteps(steps: [
                String(localized: "Open System Settings with the button below"),
                String(localized: "Turn on the switch next to Kropic in the list"),
                String(localized: "Restart Kropic if macOS asks for it"),
            ])
            .padding(.top, 6)

            HStack(spacing: 8) {
                Button("Not Now", action: onLater)
                    .buttonStyle(SecondaryButtonStyle())
                Button("Open System Settings") {
                    permissions.requestScreenRecordingAccess()
                    permissions.openScreenRecordingSettings()
                }
                .buttonStyle(PrimaryButtonStyle())
                .keyboardShortcut(.defaultAction)
            }
            .padding(.top, 8)

            Button("I've allowed it, restart Kropic", action: restart)
                .buttonStyle(.link)
                .font(.smallButton)
                .tint(.accent)
                .frame(height: 24)

            if let errorMessage {
                Text(verbatim: errorMessage)
                    .font(.smallButton)
                    .foregroundStyle(Color.danger)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 48)
        .padding(.top, 4)
        .padding(.bottom, 28)
        .frame(width: 560)
        .background(Color.panelBackground.ignoresSafeArea())
    }

    private func restart() {
        Task {
            do {
                try await permissions.relaunch()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
