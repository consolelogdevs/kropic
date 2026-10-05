import CoreGraphics

/// What to do with the selected area, chosen in the capture toolbar.
enum CaptureAction: Equatable {
    /// Recognize the text and open the result panel.
    case translate
    case copyImage
    case saveImage
    /// `anchor` is the toolbar's frame in AppKit global coordinates, for placing the share menu.
    case shareImage(anchor: CGRect)
}
