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
        let hostingController = NSHostingController(rootView: ResultView(model: model, onRetry: onRetry))
        panel.contentViewController = hostingController

        let contentSize = hostingController.view.fittingSize
        let frameSize = panel.frameRect(forContentRect: CGRect(origin: .zero, size: contentSize)).size
        let visible = ScreenGeometry.displayLocalRect(fromGlobal: selection.visibleFrame, displayFrame: selection.displayFrame)
        let local = Placement.panelFrame(size: frameSize, beside: selection.rect, in: visible, gap: Self.gap)
        let global = ScreenGeometry.globalRect(fromDisplayLocal: local, displayFrame: selection.displayFrame)
        panel.setFrame(global, display: true)

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
