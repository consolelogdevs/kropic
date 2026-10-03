import CoreGraphics
import Testing
@testable import KropicCore

struct PlacementTests {
    let bounds = CGRect(x: 0, y: 0, width: 1000, height: 800)
    let button = CGSize(width: 32, height: 32)
    let panel = CGSize(width: 400, height: 300)

    @Test func confirmButtonBelowBottomRight() {
        let selection = CGRect(x: 100, y: 100, width: 200, height: 100)
        let frame = Placement.confirmButtonFrame(size: button, selection: selection, bounds: bounds, gap: 8)
        #expect(frame == CGRect(x: 268, y: 208, width: 32, height: 32))
    }

    @Test func confirmButtonAboveWhenNoRoomBelow() {
        let selection = CGRect(x: 100, y: 700, width: 200, height: 90)
        let frame = Placement.confirmButtonFrame(size: button, selection: selection, bounds: bounds, gap: 8)
        #expect(frame == CGRect(x: 268, y: 660, width: 32, height: 32))
    }

    @Test func confirmButtonInsideWhenSelectionFillsScreen() {
        let frame = Placement.confirmButtonFrame(size: button, selection: bounds, bounds: bounds, gap: 8)
        #expect(frame == CGRect(x: 960, y: 760, width: 32, height: 32))
    }

    @Test func confirmButtonStaysOnScreenForTinySelectionAtLeftEdge() {
        let selection = CGRect(x: 0, y: 100, width: 10, height: 10)
        let frame = Placement.confirmButtonFrame(size: button, selection: selection, bounds: bounds, gap: 8)
        #expect(frame.minX == 0)
    }

    @Test func panelGoesRightFirst() {
        let selection = CGRect(x: 100, y: 100, width: 200, height: 100)
        let frame = Placement.panelFrame(size: panel, beside: selection, in: bounds, gap: 12)
        #expect(frame == CGRect(x: 312, y: 100, width: 400, height: 300))
    }

    @Test func panelGoesLeftWhenRightIsFull() {
        let selection = CGRect(x: 600, y: 600, width: 300, height: 100)
        let frame = Placement.panelFrame(size: panel, beside: selection, in: bounds, gap: 12)
        // Aligned with the selection's top, pushed up so it stays inside.
        #expect(frame == CGRect(x: 188, y: 500, width: 400, height: 300))
    }

    @Test func panelGoesBelowForWideSelection() {
        let selection = CGRect(x: 50, y: 100, width: 900, height: 100)
        let frame = Placement.panelFrame(size: panel, beside: selection, in: bounds, gap: 12)
        #expect(frame == CGRect(x: 50, y: 212, width: 400, height: 300))
    }

    @Test func panelStaysInsideWhenNoSideIsFree() {
        let frame = Placement.panelFrame(size: panel, beside: bounds, in: bounds, gap: 12)
        #expect(bounds.contains(frame))
    }

    @Test func fittedScalesDownOnly() {
        #expect(Placement.fitted(CGSize(width: 800, height: 400), maxSide: 400) == CGSize(width: 400, height: 200))
        #expect(Placement.fitted(CGSize(width: 100, height: 50), maxSide: 400) == CGSize(width: 100, height: 50))
    }
}
