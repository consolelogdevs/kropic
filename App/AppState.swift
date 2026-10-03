import CoreGraphics
import KropicCore
import Observation
import os

/// Top-level coordinator. Every way of starting a capture ends up in `startCapture()`.
@MainActor
@Observable
final class AppState {
    let settings = AppSettings()
    private let permissions = PermissionService()
    private let hotkeys = HotkeyService()
    private let launchAtLogin = LaunchAtLogin()
    private let history = HistoryViewModel(store: HistoryStore(fileURL: HistoryStore.defaultFileURL()))
    private let onboarding: HostingWindowController<OnboardingView>
    private var settingsWindow: HostingWindowController<SettingsView>?
    private var historyWindow: HostingWindowController<HistoryView>?
    private var currentResult: ResultViewModel?
    private let overlay = SelectionOverlayController()
    private let capture = CaptureService()
    private let resultPanel = ResultPanelController()
    private let focus = FocusRestorer()
    private let recognizer = TextRecognizer()
    private var recognition: Task<Void, Never>?
    private let logger = Logger(subsystem: "app.kropic", category: "AppState")

    init() {
        let permissions = permissions
        onboarding = HostingWindowController(title: "Welcome to Kropic") {
            OnboardingView(permissions: permissions)
        }
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

    func showSettings() {
        if settingsWindow == nil {
            let settings = settings
            let launchAtLogin = launchAtLogin
            let history = history
            settingsWindow = HostingWindowController(title: "Kropic Settings") {
                SettingsView(settings: settings, launchAtLogin: launchAtLogin) {
                    try await history.clear()
                }
            }
        }
        settingsWindow?.show()
    }

    func showHistory() {
        if historyWindow == nil {
            let history = history
            let settings = settings
            historyWindow = HostingWindowController(title: "Kropic History", resizable: true) {
                HistoryView(model: history, settings: settings)
            }
        }
        historyWindow?.show()
    }

    private func runCapture() async {
        recognition?.cancel()
        recognition = nil
        archiveCurrentResult()
        resultPanel.close()
        focus.activateKropic()
        guard let selection = await overlay.select() else {
            logger.info("Selection cancelled")
            focus.restore()
            return
        }

        let model: ResultViewModel
        let image: CGImage
        do {
            image = try await capture.capture(selection.rect, on: selection.displayID)
            model = ResultViewModel(image: image, scale: CGFloat(image.width) / selection.rect.width, settings: settings)
        } catch {
            logger.error("Capture failed: \(String(describing: error))")
            showResult(ResultViewModel(captureFailure: error.localizedDescription, settings: settings), near: selection)
            return
        }

        showResult(model, near: selection)
        recognition = Task { [recognizer] in
            do throws(OCRError) {
                model.show(try await recognizer.recognize(image))
            } catch {
                if error != .cancelled {
                    model.showFailure(error.localizedDescription)
                }
            }
        }
    }

    private func showResult(_ model: ResultViewModel, near selection: SelectionResult) {
        currentResult = model
        resultPanel.show(model, near: selection) { [weak self] in
            self?.startCapture()
        } onClose: { [weak self] in
            self?.recognition?.cancel()
            self?.archiveCurrentResult()
            self?.focus.restore()
        }
    }

    /// Saves the open result to history, once, when its panel closes or is replaced.
    private func archiveCurrentResult() {
        defer { currentResult = nil }
        guard settings.saveHistory, let entry = currentResult?.historyEntry else { return }
        Task { [history] in
            await history.add(entry)
        }
    }
}
