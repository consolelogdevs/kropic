import CoreGraphics

/// Conversions between AppKit's global screen space and a display's local space.
///
/// - AppKit global: points, origin at the bottom-left of the primary display, y grows upward.
/// - Display-local: points, origin at the top-left of one display, y grows downward.
///   This is what SwiftUI views covering the display and ScreenCaptureKit's `sourceRect` use.
public enum ScreenGeometry {
    public static func displayLocalRect(fromGlobal rect: CGRect, displayFrame: CGRect) -> CGRect {
        CGRect(
            x: rect.minX - displayFrame.minX,
            y: displayFrame.maxY - rect.maxY,
            width: rect.width,
            height: rect.height
        )
    }

    public static func globalRect(fromDisplayLocal rect: CGRect, displayFrame: CGRect) -> CGRect {
        CGRect(
            x: displayFrame.minX + rect.minX,
            y: displayFrame.maxY - rect.maxY,
            width: rect.width,
            height: rect.height
        )
    }

    /// Pixel dimensions for a size in points on a display with the given backing scale.
    public static func pixelSize(of size: CGSize, scale: CGFloat) -> PixelSize {
        PixelSize(
            width: Int((size.width * scale).rounded()),
            height: Int((size.height * scale).rounded())
        )
    }
}

public struct PixelSize: Sendable, Equatable {
    public var width: Int
    public var height: Int

    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}
