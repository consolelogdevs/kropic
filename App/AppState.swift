import CoreGraphics
import Observation
import os

/// Top-level coordinator. Every way of starting a capture ends up in `startCapture()`.
@MainActor
@Observable
final class AppState {
    private let permissions = PermissionService()
    private let hotkeys = HotkeyService()
    private let onboarding: OnboardingWindowController
    private let overlay = SelectionOverlayController()
    private let capture = CaptureService()
    private let resultPanel = ResultPanelController()
    private let focus = FocusRestorer()
    private let logger = Logger(subsystem: "app.kropic", category: "AppState")

    init() {
        onboarding = OnboardingWindowController(permissions: permissions)
    }

    func start() {
        hotkeys.start { [weak self] in
            self?.startCapture()
        }
        if !permissions.hasScreenRecordingAccess {
            onboarding.show()
        }
    }

    func startCapture() {
        guard permissions.hasScreenRecordingAccess else {
            logger.info("Capture requested without Screen Recording permission")
            onboarding.show()
            return
        }
        guard !overlay.isPresented else { return }
        Task {
            await runCapture()
        }
    }

    private func runCapture() async {
        resultPanel.close()
        focus.activateKropic()
        guard let selection = await overlay.select() else {
            logger.info("Selection cancelled")
            focus.restore()
            return
        }

        let content: ResultViewModel.Content
        do {
            let image = try await capture.capture(selection.rect, on: selection.displayID)
            content = .image(image, scale: CGFloat(image.width) / selection.rect.width)
        } catch {
            logger.error("Capture failed: \(String(describing: error))")
            content = .failure(error.localizedDescription)
        }
        resultPanel.show(ResultViewModel(content: content), near: selection) { [weak self] in
            self?.focus.restore()
        }
    }
}
