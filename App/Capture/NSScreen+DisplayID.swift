import AppKit

extension NSScreen {
    /// The CoreGraphics display ID, which ScreenCaptureKit uses to identify the same display.
    var displayID: CGDirectDisplayID? {
        (deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value
    }
}
