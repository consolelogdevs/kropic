import AppKit
import SwiftUI

/// Frosted glass that blurs whatever is on screen behind the window: a live preview of the
/// blur and pixelate marks in the transparent overlay.
struct BehindWindowBlur: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.material = .fullScreenUI
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
