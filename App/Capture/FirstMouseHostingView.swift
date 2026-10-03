import SwiftUI

/// A hosting view that handles the first click even when its window is not key,
/// so a drag on a second display starts a selection right away.
final class FirstMouseHostingView<Content: View>: NSHostingView<Content> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}
