import AppKit
import ImageIO
import UniformTypeIdentifiers

/// Copies and saves captured images. Saving writes only to the place the user picks in the
/// Save dialog (D-052); nothing else in Kropic writes images to disk.
@MainActor
enum ImageExporter {
    static func copy(_ image: CGImage, scale: CGFloat) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([nsImage(image, scale: scale)])
    }

    /// Shows the Save dialog and writes a PNG. Returns `false` when the user cancels.
    static func save(_ image: CGImage, scale: CGFloat) async throws(ImageSaveError) -> Bool {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = defaultFileName()
        NSApp.activate()
        guard await panel.begin() == .OK, let url = panel.url else { return false }
        try write(image, scale: scale, to: url)
        return true
    }

    static func nsImage(_ image: CGImage, scale: CGFloat) -> NSImage {
        NSImage(cgImage: image, size: NSSize(width: CGFloat(image.width) / scale, height: CGFloat(image.height) / scale))
    }

    /// "Kropic 2026-10-05 at 22.41.07.png", like macOS screenshots.
    private static func defaultFileName() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd 'at' HH.mm.ss"
        return "Kropic \(formatter.string(from: Date())).png"
    }

    /// PNG with the display's DPI, so the file opens at its on-screen size.
    private static func write(_ image: CGImage, scale: CGFloat, to url: URL) throws(ImageSaveError) {
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
            throw .writeFailed
        }
        let dpi = 72 * scale
        CGImageDestinationAddImage(destination, image, [
            kCGImagePropertyDPIWidth: dpi,
            kCGImagePropertyDPIHeight: dpi,
        ] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { throw .writeFailed }
    }
}
