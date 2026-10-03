import AppKit
import KropicCore
import SwiftUI

@MainActor
final class ResultPanelController {
    private static let gap: CGFloat = 12
    private var panel: ResultPanel?

    func show(_ model: ResultViewModel, near selection: SelectionResult, onClose: @escaping () -> Void) {
        close()

        let panel = ResultPanel()
        panel.onClose = onClose
        let hostingController = NSHostingController(rootView: ResultView(model: model))
        panel.contentViewController = hostingController

        let contentSize = hostingController.view.fittingSize
        let frameSize = panel.frameRect(forContentRect: CGRect(origin: .zero, size: contentSize)).size
        let visible = ScreenGeometry.displayLocalRect(fromGlobal: selection.visibleFrame, displayFrame: selection.displayFrame)
        let local = Placement.panelFrame(size: frameSize, beside: selection.rect, in: visible, gap: Self.gap)
        let global = ScreenGeometry.globalRect(fromDisplayLocal: local, displayFrame: selection.displayFrame)
        panel.setFrame(global, display: true)

        panel.makeKeyAndOrderFront(nil)
        self.panel = panel
    }

    /// Closes the panel without running its close callback, for when a new capture replaces it.
    func close() {
        panel?.onClose = nil
        panel?.close()
        panel = nil
    }
}
