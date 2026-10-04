#if DEBUG
import AppKit
import SwiftUI

/// Renders design previews to PNG in light and dark, for comparison with `design/screens/`.
/// Debug builds only. Run the app binary with `-renderPreviews`; files go to the app's
/// sandbox temporary directory and the path is printed. Previews use sample data only,
/// never captured images.
@MainActor
enum PreviewRenderer {
    static let argument = "-renderPreviews"

    private struct Entry {
        let name: String
        let view: AnyView
    }

    private static var entries: [Entry] {
        [
            Entry(name: "Tokens", view: AnyView(TokenSwatchView())),
            Entry(name: "Components", view: AnyView(ComponentGalleryView())),
            Entry(name: "Main", view: AnyView(ResultPreviews.main)),
            Entry(name: "Loading", view: AnyView(ResultPreviews.loading)),
            Entry(name: "NoText", view: AnyView(ResultPreviews.noText)),
            Entry(name: "LangPack", view: AnyView(ResultPreviews.languagePack)),
            Entry(name: "LongText", view: AnyView(ResultPreviews.longText)),
        ]
    }

    static func renderAll() -> URL {
        let directory = FileManager.default.temporaryDirectory.appending(path: "renders")
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        for entry in entries {
            for (suffix, appearance) in [("", NSAppearance.Name.aqua), ("Dark", .darkAqua)] {
                if let data = snapshot(entry.view, appearance: appearance) {
                    try? data.write(to: directory.appending(path: "\(entry.name)\(suffix).png"))
                }
            }
        }
        return directory
    }

    /// Draws the view through AppKit, so native controls (switches, pop-ups, text fields) render.
    /// `ImageRenderer` replaces those with placeholders. The window is key, so controls draw in
    /// their active state, and sits off-screen. The bitmap is converted to sRGB to match the spec.
    private static func snapshot(_ view: AnyView, appearance: NSAppearance.Name) -> Data? {
        // Launched from a terminal the app cannot become active, so tell SwiftUI controls they are.
        let hostingView = NSHostingView(rootView: view.environment(\.controlActiveState, .key))
        let size = hostingView.fittingSize
        let window = RenderWindow(contentRect: CGRect(x: -20_000, y: -20_000, width: size.width, height: size.height))
        window.appearance = NSAppearance(named: appearance)
        window.contentView = hostingView
        window.makeKeyAndOrderFront(nil)
        hostingView.frame = CGRect(origin: .zero, size: size)
        hostingView.layoutSubtreeIfNeeded()
        defer { window.orderOut(nil) }
        guard let bitmap = hostingView.bitmapImageRepForCachingDisplay(in: hostingView.bounds) else { return nil }
        hostingView.cacheDisplay(in: hostingView.bounds, to: bitmap)
        let srgb = bitmap.converting(to: .sRGB, renderingIntent: .default) ?? bitmap
        return srgb.representation(using: .png, properties: [:])
    }
}

private final class RenderWindow: NSWindow {
    init(contentRect: CGRect) {
        super.init(contentRect: contentRect, styleMask: [.borderless], backing: .buffered, defer: false)
        isReleasedWhenClosed = false
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
#endif
