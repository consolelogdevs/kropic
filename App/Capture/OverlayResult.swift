import KropicCore

/// What the overlay hands back: the area, the marks drawn on it and the chosen action.
struct OverlayResult {
    let selection: SelectionResult
    /// In the selection display's local points, origin top-left.
    let annotations: [Annotation]
    let action: CaptureAction
}
