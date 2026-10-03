import SwiftUI

struct OnboardingView: View {
    let permissions: PermissionService

    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Kropic needs screen recording access", systemImage: "text.viewfinder")
                .font(.title3.bold())

            Text("Kropic reads text from the part of the screen you select. macOS treats that as screen recording, so turn Kropic on in System Settings under Privacy & Security → Screen & System Audio Recording. Images never leave your Mac and are never saved.")
                .fixedSize(horizontal: false, vertical: true)

            Text("After you turn it on, macOS usually needs Kropic to restart.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack {
                Spacer()
                Button("Restart Kropic") {
                    restart()
                }
                Button("Open System Settings") {
                    permissions.requestScreenRecordingAccess()
                    permissions.openScreenRecordingSettings()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 420)
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
