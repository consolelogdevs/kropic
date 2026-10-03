import AppKit

/// A borderless, transparent panel covering one display while the user selects an area.
///
/// Mouse events are read here, before SwiftUI sees them, and forwarded as display-local
/// points (origin top-left). Returning `false` from `onMouse` lets SwiftUI handle the event,
/// which is how the confirm button still receives its click.
final class SelectionOverlayPanel: NSPanel {
    enum MousePhase {
        case down, dragged, up
    }

    var onMouse: ((MousePhase, CGPoint) -> Bool)?

    init(screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        level = .screenSaver
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        // Transparent windows let clicks pass through areas the window server sees as empty,
        // and SwiftUI's layers do not count. Setting this explicitly makes the whole panel clickable.
        ignoresMouseEvents = false
        isMovable = false
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        setFrame(screen.frame, display: false)
    }

    override var canBecomeKey: Bool { true }

    override func sendEvent(_ event: NSEvent) {
        if let phase = Self.mousePhase(of: event) {
            // The window covers the whole display, so window coordinates are display coordinates
            // with a flipped y axis.
            let location = CGPoint(x: event.locationInWindow.x, y: frame.height - event.locationInWindow.y)
            if onMouse?(phase, location) == true {
                return
            }
        }
        super.sendEvent(event)
    }

    private static func mousePhase(of event: NSEvent) -> MousePhase? {
        switch event.type {
        case .leftMouseDown: .down
        case .leftMouseDragged: .dragged
        case .leftMouseUp: .up
        default: nil
        }
    }
}
