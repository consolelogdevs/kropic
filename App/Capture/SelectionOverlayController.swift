import AppKit
import SwiftUI

/// Puts an overlay on every display and waits until the user confirms or cancels.
@MainActor
final class SelectionOverlayController {
    private var panels: [SelectionOverlayPanel] = []
    private var model = SelectionModel()
    private var continuation: CheckedContinuation<SelectionResult?, Never>?
    private var keyMonitor: Any?
    private var dragStart: CGPoint?

    var isPresented: Bool { continuation != nil }


    /// Returns the confirmed selection, or `nil` when the user cancels.
    func select() async -> SelectionResult? {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            present()
        }
    }

    private func present() {
        model = SelectionModel()
        let mouseLocation = NSEvent.mouseLocation

        for screen in NSScreen.screens {
            guard let displayID = screen.displayID else { continue }
            let panel = SelectionOverlayPanel(screen: screen)
            let bounds = CGRect(origin: .zero, size: screen.frame.size)
            panel.onMouse = { [weak self] phase, location in
                self?.handleMouse(phase, at: location, on: displayID, bounds: bounds) ?? false
            }

            let view = SelectionOverlayView(
                model: model,
                displayID: displayID,
                // The hint pill appears on the display under the cursor, on every capture (D-045).
                showsHint: screen.frame.contains(mouseLocation),
                // The panel covers the menu bar; the hint goes just below it.
                hintTopInset: screen.frame.maxY - screen.visibleFrame.maxY,
                onConfirm: { [weak self] in self?.confirm() },
                onCancel: { [weak self] in self?.finish(with: nil) }
            )
            let hostingView = FirstMouseHostingView(rootView: view)
            // The panel's size is fixed to the display; never let SwiftUI resize it.
            hostingView.sizingOptions = []
            panel.contentView = hostingView
            panel.orderFrontRegardless()
            panels.append(panel)

            if screen.frame.contains(mouseLocation) {
                panel.makeKeyAndOrderFront(nil)
            }
        }
        if !panels.contains(where: \.isKeyWindow) {
            panels.first?.makeKeyAndOrderFront(nil)
        }

        // An app-wide key monitor works no matter which of our windows AppKit made key.
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            switch event.keyCode {
            case KeyCode.escape:
                self.finish(with: nil)
                return nil
            case KeyCode.returnKey, KeyCode.keypadEnter:
                self.confirm()
                return nil
            default:
                return event
            }
        }
    }

    /// Returns `true` when the event was handled and should not reach SwiftUI.
    private func handleMouse(_ phase: SelectionOverlayPanel.MousePhase, at location: CGPoint, on displayID: CGDirectDisplayID, bounds: CGRect) -> Bool {
        switch phase {
        case .down:
            if let bar = model.actionBarFrame(on: displayID, bounds: bounds), bar.contains(location) {
                return false
            }
            dragStart = location
            model.dragChanged(on: displayID, bounds: bounds, start: location, location: location, translation: .zero)
        case .dragged:
            guard let start = dragStart else { return false }
            let translation = CGSize(width: location.x - start.x, height: location.y - start.y)
            model.dragChanged(on: displayID, bounds: bounds, start: start, location: location, translation: translation)
        case .up:
            guard dragStart != nil else { return false }
            dragStart = nil
            model.dragEnded()
        }
        return true
    }

    private func confirm() {
        guard model.canConfirm,
              let displayID = model.displayID,
              let rect = model.rect,
              let screen = NSScreen.screens.first(where: { $0.displayID == displayID })
        else { return }

        finish(with: SelectionResult(
            displayID: displayID,
            rect: rect,
            displayFrame: screen.frame,
            visibleFrame: screen.visibleFrame
        ))
    }

    private func finish(with result: SelectionResult?) {
        if let keyMonitor {
            NSEvent.removeMonitor(keyMonitor)
        }
        keyMonitor = nil
        dragStart = nil
        for panel in panels {
            panel.orderOut(nil)
        }
        panels.removeAll()
        continuation?.resume(returning: result)
        continuation = nil
    }
}
