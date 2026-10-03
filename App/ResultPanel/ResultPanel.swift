import AppKit

/// Floating panel that shows a capture result next to the selection.
final class ResultPanel: NSPanel {
    var onClose: (() -> Void)?

    init() {
        super.init(
            contentRect: .zero,
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: true
        )
        title = "Kropic"
        level = .floating
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        collectionBehavior = [.fullScreenAuxiliary, .moveToActiveSpace]
    }

    override var canBecomeKey: Bool { true }

    override func close() {
        super.close()
        onClose?()
        onClose = nil
    }

    override func sendEvent(_ event: NSEvent) {
        if event.type == .keyDown, event.keyCode == KeyCode.escape {
            close()
            return
        }
        super.sendEvent(event)
    }
}
