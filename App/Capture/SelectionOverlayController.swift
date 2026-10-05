import AppKit
import KropicCore
import SwiftUI

/// Puts an overlay on every display, lets the user select and annotate an area, and waits for
/// an action from the capture toolbar (translate, copy, save, share) or a cancel.
@MainActor
final class SelectionOverlayController {
    private enum Drag {
        case selection(start: CGPoint)
        case annotation(start: CGPoint)
        case mark(start: CGPoint)
    }

    /// Takes an in-memory picture of a display (size in points) for the blur and pixelate
    /// previews. Kropic's own windows are left out.
    typealias SnapshotProvider = @MainActor (CGDirectDisplayID, CGSize) async -> CGImage?

    private var panels: [SelectionOverlayPanel] = []
    private var model = SelectionModel()
    private var annotations = OverlayAnnotations()
    private var continuation: CheckedContinuation<OverlayResult?, Never>?
    private var keyMonitor: Any?
    private var drag: Drag?
    private var snapshotTask: Task<Void, Never>?

    var isPresented: Bool { continuation != nil }

    /// Returns the area, its marks and the chosen action, or `nil` when the user cancels.
    func select(snapshot: @escaping SnapshotProvider) async -> OverlayResult? {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            present()
            takeSnapshots(with: snapshot)
        }
    }

    private func takeSnapshots(with provider: @escaping SnapshotProvider) {
        let displays = NSScreen.screens.compactMap { screen in screen.displayID.map { ($0, screen.frame.size) } }
        let annotations = annotations
        snapshotTask = Task {
            for (displayID, size) in displays {
                guard !Task.isCancelled else { return }
                if let image = await provider(displayID, size) {
                    annotations.setSnapshot(.init(image: image, scale: CGFloat(image.width) / size.width), for: displayID)
                }
            }
        }
    }

    private func present() {
        model = SelectionModel()
        annotations = OverlayAnnotations()
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
                annotations: annotations,
                displayID: displayID,
                // The hint pill appears on the display under the cursor, on every capture (D-045).
                showsHint: screen.frame.contains(mouseLocation),
                // The panel covers the menu bar; the hint goes just below it.
                hintTopInset: screen.frame.maxY - screen.visibleFrame.maxY,
                onAction: { [weak self] action in self?.perform(action) }
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
            return self.handleKey(event) ? nil : event
        }
    }

    // MARK: Input

    /// Returns `true` when the event was handled and should not reach SwiftUI.
    private func handleMouse(_ phase: SelectionOverlayPanel.MousePhase, at location: CGPoint, on displayID: CGDirectDisplayID, bounds: CGRect) -> Bool {
        switch phase {
        case .down:
            if let toolbar = model.toolbarFrame(on: displayID, bounds: bounds), toolbar.contains(location) {
                return false
            }
            annotations.commitText()
            let target = model.hitTarget(at: location, on: displayID)
            if annotations.tool != nil, target == .inside {
                drag = .annotation(start: location)
            } else if annotations.tool == nil, target == .inside, annotations.beginMove(at: location) {
                drag = .mark(start: location)
            } else {
                drag = .selection(start: location)
                let startsNewSelection = model.hitTarget(at: location, on: displayID) == .outside
                model.dragChanged(on: displayID, bounds: bounds, start: location, location: location, translation: .zero)
                if startsNewSelection {
                    annotations.reset()
                }
            }

        case .dragged:
            switch drag {
            case .selection(let start):
                let translation = CGSize(width: location.x - start.x, height: location.y - start.y)
                model.dragChanged(on: displayID, bounds: bounds, start: start, location: location, translation: translation)
            case .annotation(let start):
                if let area = model.rect(on: displayID) {
                    annotations.dragChanged(from: start, to: location, in: area)
                }
            case .mark(let start):
                annotations.move(by: CGSize(width: location.x - start.x, height: location.y - start.y))
            case nil:
                return false
            }

        case .up:
            switch drag {
            case .selection:
                model.dragEnded()
            case .annotation(let start):
                if let area = model.rect(on: displayID) {
                    annotations.dragEnded(from: start, to: location, in: area)
                }
            case .mark:
                annotations.endMove()
            case nil:
                return false
            }
            drag = nil
        }
        return true
    }

    /// Returns `true` when the key was handled.
    private func handleKey(_ event: NSEvent) -> Bool {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        if annotations.isEditingText {
            switch event.keyCode {
            case KeyCode.escape:
                annotations.cancelText()
                return true
            case KeyCode.returnKey, KeyCode.keypadEnter:
                annotations.commitText()
                return true
            default:
                return false   // typing goes to the text field
            }
        }

        switch event.keyCode {
        case KeyCode.escape:
            finish(with: nil)
            return true
        case KeyCode.returnKey, KeyCode.keypadEnter:
            perform(.translate)
            return true
        case KeyCode.delete, KeyCode.forwardDelete:
            guard annotations.selectedID != nil else { return false }
            annotations.deleteSelection()
            return true
        default:
            break
        }

        guard model.canConfirm, let key = event.charactersIgnoringModifiers?.lowercased().first else { return false }
        switch (modifiers, key) {
        case (.command, "c"): perform(.copy)
        case (.command, "s"): perform(.save)
        case (.command, "z"): annotations.undo()
        case ([.command, .shift], "z"): annotations.redo()
        case ([], "v"): annotations.tool = nil
        case ([], _):
            guard let tool = AnnotationTool.allCases.first(where: { $0.shortcut == key }) else { return false }
            annotations.tool = tool
        default:
            return false
        }
        return true
    }

    // MARK: Actions

    private func perform(_ action: CaptureToolbar.ToolbarAction) {
        switch action {
        case .cancel:
            finish(with: nil)
        case .translate:
            complete(with: .translate)
        case .copy:
            complete(with: .copyImage)
        case .save:
            complete(with: .saveImage)
        case .share:
            guard let displayID = model.displayID,
                  let screen = NSScreen.screens.first(where: { $0.displayID == displayID }),
                  let toolbar = model.toolbarFrame(on: displayID, bounds: CGRect(origin: .zero, size: screen.frame.size))
            else { return }
            let anchor = ScreenGeometry.globalRect(fromDisplayLocal: toolbar, displayFrame: screen.frame)
            complete(with: .shareImage(anchor: anchor))
        }
    }

    private func complete(with action: CaptureAction) {
        annotations.commitText()
        guard model.canConfirm,
              let displayID = model.displayID,
              let rect = model.rect,
              let screen = NSScreen.screens.first(where: { $0.displayID == displayID })
        else { return }

        let selection = SelectionResult(
            displayID: displayID,
            rect: rect,
            displayFrame: screen.frame,
            visibleFrame: screen.visibleFrame
        )
        finish(with: OverlayResult(selection: selection, annotations: annotations.annotations, action: action))
    }

    private func finish(with result: OverlayResult?) {
        if let keyMonitor {
            NSEvent.removeMonitor(keyMonitor)
        }
        keyMonitor = nil
        drag = nil
        snapshotTask?.cancel()
        snapshotTask = nil
        for panel in panels {
            panel.orderOut(nil)
        }
        panels.removeAll()
        continuation?.resume(returning: result)
        continuation = nil
    }
}
