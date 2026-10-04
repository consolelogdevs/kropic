import AppKit

/// Floating, frameless panel that shows a capture result next to the selection.
/// The SwiftUI content draws the rounded window, header and footer.
final class ResultPanel: NSPanel {
    var onClose: (() -> Void)?
    var onCopyText: (() -> Void)?
    var onCopyTranslation: (() -> Void)?

    init() {
        super.init(
            contentRect: .zero,
            styleMask: [.borderless],
            backing: .buffered,
            defer: true
        )
        level = .floating
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
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

    /// Changes the height while keeping the top edge where it is, so the panel grows downward
    /// for long text. It never gets taller than the screen and is moved up only as far as
    /// needed to stay on it.
    func setHeightKeepingTop(_ height: CGFloat) {
        guard height != frame.height else { return }
        let visible = screen?.visibleFrame ?? frame
        var rect = frame
        rect.size.height = min(height, visible.height)
        rect.origin.y = frame.maxY - rect.height
        if rect.minY < visible.minY {
            rect.origin.y = visible.minY
        }
        setFrame(rect, display: true)
        // The shadow follows the rounded content, so it has to be recomputed after a resize.
        invalidateShadow()
    }

    override func sendEvent(_ event: NSEvent) {
        if event.type == .keyDown, handleKey(event) {
            return
        }
        super.sendEvent(event)
    }

    private func handleKey(_ event: NSEvent) -> Bool {
        if event.keyCode == KeyCode.escape {
            close()
            return true
        }
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        guard event.charactersIgnoringModifiers?.lowercased() == "c" else { return false }
        if modifiers == [.command, .shift] {
            onCopyTranslation?()
            return true
        }
        if modifiers == .command {
            // A selection inside a text field copies normally; otherwise ⌘C copies all extracted text.
            if let textView = firstResponder as? NSTextView, textView.selectedRange().length > 0 {
                return false
            }
            onCopyText?()
            return true
        }
        return false
    }
}
