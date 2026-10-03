import CoreGraphics

/// A confirmed selection. `rect` is display-local: points, origin at the display's top-left.
struct SelectionResult: Sendable {
    let displayID: CGDirectDisplayID
    let rect: CGRect
    /// The display's frame in AppKit global coordinates.
    let displayFrame: CGRect
    /// The display's frame minus menu bar and Dock, in AppKit global coordinates.
    let visibleFrame: CGRect
}
