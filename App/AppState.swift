import AppKit
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
    let history = HistoryViewModel(store: HistoryStore(fileURL: HistoryStore.defaultFileURL()))
    private var onboardingWindow: HostingWindowController<OnboardingView>?
    private var settingsWindow: HostingWindowController<SettingsView>?
    private var historyWindow: HostingWindowController<HistoryView>?
    private var currentResult: ResultViewModel?
    private let overlay: SelectionOverlayController
    private let capture = CaptureService()
    private let resultPanel = ResultPanelController()
    private let focus = FocusRestorer()
    private let sharePresenter = SharePresenter()
    private let recognizer = TextRecognizer()
    private var recognition: Task<Void, Never>?
    private let logger = Logger(subsystem: "app.kropic", category: "AppState")

    init() {
        overlay = SelectionOverlayController()
    }

    func start() {
        AppearanceService.apply(settings.appearance)
        hotkeys.start { [weak self] in
            self?.startCapture()
        }
        if !permissions.hasScreenRecordingAccess {
            showOnboarding()
        }
        // Load history now so the menu's Recent Translations are there on first open.
        Task { [history] in
            await history.reload()
        }
    }

    func showAbout() {
        NSApp.activate()
        NSApp.orderFrontStandardAboutPanel(nil)
    }

    func startCapture() {
        guard permissions.hasScreenRecordingAccess else {
            logger.info("Capture requested without Screen Recording permission")
            showOnboarding()
            return
        }
        guard !overlay.isPresented else { return }
        Task {
            await runCapture()
        }
    }

    func showOnboarding() {
        if onboardingWindow == nil {
            let permissions = permissions
            onboardingWindow = HostingWindowController(title: String(localized: "Welcome to Kropic"), titleBar: .transparent) {
                OnboardingView(permissions: permissions) { [weak self] in
                    self?.onboardingWindow?.close()
                }
            }
        }
        onboardingWindow?.show()
    }

    func showSettings() {
        if settingsWindow == nil {
            let settings = settings
            let launchAtLogin = launchAtLogin
            let history = history
            settingsWindow = HostingWindowController(title: String(localized: "Settings")) {
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
            historyWindow = HostingWindowController(title: String(localized: "Kropic History"), resizable: true) {
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
        let capture = capture
        guard let result = await overlay.select(snapshot: { displayID, size in
            try? await capture.capture(CGRect(origin: .zero, size: size), on: displayID)
        }) else {
            logger.info("Selection cancelled")
            focus.restore()
            return
        }
        let selection = result.selection

        let captured: CGImage
        do {
            captured = try await capture.capture(selection.rect, on: selection.displayID)
        } catch {
            logger.error("Capture failed: \(String(describing: error))")
            if result.action == .translate {
                showResult(ResultViewModel(captureFailure: error.localizedDescription, selectionSize: selection.rect.size, settings: settings), near: selection)
            } else {
                showError(error.localizedDescription)
            }
            return
        }

        // Burn the marks into the image. Everything below, OCR included, uses this version,
        // so blurred or pixelated text is never read (D-053).
        let scale = CGFloat(captured.width) / selection.rect.width
        let marks = result.annotations.map { $0.converted(origin: selection.rect.origin, scale: scale) }
        let image = marks.isEmpty ? captured : (AnnotationRenderer.render(marks, onto: captured) ?? captured)

        switch result.action {
        case .translate:
            translate(image, scale: scale, selection: selection)
        case .copyImage:
            ImageExporter.copy(image, scale: scale)
            focus.restore()
        case .saveImage:
            do {
                _ = try await ImageExporter.save(image, scale: scale)
            } catch {
                showError(error.localizedDescription)
            }
            focus.restore()
        case .shareImage(let anchor):
            sharePresenter.share(ImageExporter.nsImage(image, scale: scale), at: anchor) { [weak self] in
                self?.focus.restore()
            }
        }
    }

    private func translate(_ image: CGImage, scale: CGFloat, selection: SelectionResult) {
        let model = ResultViewModel(image: image, scale: scale, selectionSize: selection.rect.size, settings: settings)
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

    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = message
        NSApp.activate()
        alert.runModal()
        focus.restore()
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
