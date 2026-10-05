import AppKit

/// Shows the macOS share menu for an image after the overlay has closed. The menu needs a view
/// to attach to, so a small invisible window stands in at the toolbar's old position.
@MainActor
final class SharePresenter: NSObject, NSSharingServicePickerDelegate {
    private var anchorWindow: NSWindow?
    private var onFinish: (() -> Void)?

    /// `anchor` is in AppKit global coordinates.
    func share(_ image: NSImage, at anchor: CGRect, onFinish: @escaping () -> Void) {
        close()
        self.onFinish = onFinish
        let window = NSWindow(contentRect: anchor, styleMask: [.borderless], backing: .buffered, defer: false)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.isReleasedWhenClosed = false
        window.orderFrontRegardless()
        anchorWindow = window

        guard let view = window.contentView else { return }
        let picker = NSSharingServicePicker(items: [image])
        picker.delegate = self
        picker.show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
    }

    nonisolated func sharingServicePicker(_ picker: NSSharingServicePicker, didChoose service: NSSharingService?) {
        MainActor.assumeIsolated {
            close()
        }
    }

    private func close() {
        anchorWindow?.orderOut(nil)
        anchorWindow = nil
        onFinish?()
        onFinish = nil
    }
}
