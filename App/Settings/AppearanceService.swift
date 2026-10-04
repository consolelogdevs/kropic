import AppKit

/// Applies the appearance choice to the whole app. Every window and SwiftUI view follows
/// `NSApp.appearance`, so a change shows up instantly without a restart.
@MainActor
enum AppearanceService {
    static func apply(_ mode: AppearanceMode) {
        NSApp.appearance = mode.nsAppearance
    }
}
