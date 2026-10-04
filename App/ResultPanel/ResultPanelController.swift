import AppKit
import KropicCore
import SwiftUI

@MainActor
final class ResultPanelController {
    private static let gap: CGFloat = 12
    private var panel: ResultPanel?
    private var model: ResultViewModel?

    func show(_ model: ResultViewModel, near selection: SelectionResult, onRetry: @escaping () -> Void, onClose: @escaping () -> Void) {
        close()

        let panel = ResultPanel()
        panel.onClose = { [weak model] in
            model?.translation.cancel()
            onClose()
        }
        panel.onCopyText = { [weak model] in model?.copyText() }
        panel.onCopyTranslation = { [weak model] in model?.copyTranslation() }

        let view = ResultView(model: model, onCaptureAgain: onRetry) { [weak panel] in
            panel?.close()
        }
        // The hosting view sizes the window to the SwiftUI content, so the panel grows with long text.
        let hostingView = NSHostingView(rootView: view)
        panel.contentView = hostingView

        let size = hostingView.fittingSize
        let visible = ScreenGeometry.displayLocalRect(fromGlobal: selection.visibleFrame, displayFrame: selection.displayFrame)
        let local = Placement.panelFrame(size: size, beside: selection.rect, in: visible, gap: Self.gap)
        let global = ScreenGeometry.globalRect(fromDisplayLocal: local, displayFrame: selection.displayFrame)
        panel.setFrame(global, display: true)
        panel.anchorsTop = true

        panel.makeKeyAndOrderFront(nil)
        self.panel = panel
        self.model = model
    }

    /// Closes the panel without running its close callback, for when a new capture replaces it.
    func close() {
        model?.translation.cancel()
        model = nil
        panel?.onClose = nil
        panel?.close()
        panel = nil
    }
}
