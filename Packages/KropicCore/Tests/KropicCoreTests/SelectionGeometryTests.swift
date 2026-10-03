import CoreGraphics
import Testing
@testable import KropicCore

struct SelectionGeometryTests {
    let bounds = CGRect(x: 0, y: 0, width: 1000, height: 800)
    let selection = CGRect(x: 100, y: 100, width: 200, height: 100)

    @Test func rectFromDragInAnyDirection() {
        let expected = CGRect(x: 10, y: 20, width: 90, height: 60)
        #expect(SelectionGeometry.rect(from: CGPoint(x: 10, y: 20), to: CGPoint(x: 100, y: 80), within: bounds) == expected)
        #expect(SelectionGeometry.rect(from: CGPoint(x: 100, y: 80), to: CGPoint(x: 10, y: 20), within: bounds) == expected)
        #expect(SelectionGeometry.rect(from: CGPoint(x: 100, y: 20), to: CGPoint(x: 10, y: 80), within: bounds) == expected)
    }

    @Test func rectIsClampedToBounds() {
        let rect = SelectionGeometry.rect(from: CGPoint(x: 900, y: 700), to: CGPoint(x: 1200, y: 950), within: bounds)
        #expect(rect == CGRect(x: 900, y: 700, width: 100, height: 100))
    }

    @Test func moveKeepsSizeAndStaysInside() {
        let moved = SelectionGeometry.moved(selection, by: CGSize(width: 2000, height: -500), within: bounds)
        #expect(moved == CGRect(x: 800, y: 0, width: 200, height: 100))
    }

    @Test func resizeCorner() {
        let rect = SelectionGeometry.resized(selection, handle: .bottomRight, to: CGPoint(x: 350, y: 260), within: bounds)
        #expect(rect == CGRect(x: 100, y: 100, width: 250, height: 160))
    }

    @Test func resizeEdgeChangesOneAxisOnly() {
        let rect = SelectionGeometry.resized(selection, handle: .top, to: CGPoint(x: 999, y: 50), within: bounds)
        #expect(rect == CGRect(x: 100, y: 50, width: 200, height: 150))
    }

    @Test func resizePastOppositeEdgeFlips() {
        let rect = SelectionGeometry.resized(selection, handle: .left, to: CGPoint(x: 400, y: 0), within: bounds)
        #expect(rect == CGRect(x: 300, y: 100, width: 100, height: 100))
    }

    @Test func handlePointsAreOnTheRect() {
        #expect(SelectionGeometry.point(of: .topLeft, in: selection) == CGPoint(x: 100, y: 100))
        #expect(SelectionGeometry.point(of: .right, in: selection) == CGPoint(x: 300, y: 150))
        #expect(SelectionGeometry.point(of: .bottom, in: selection) == CGPoint(x: 200, y: 200))
    }

    @Test func hitTestingPrefersCorners() {
        #expect(SelectionGeometry.handle(at: CGPoint(x: 103, y: 98), in: selection, tolerance: 6) == .topLeft)
        #expect(SelectionGeometry.handle(at: CGPoint(x: 302, y: 199), in: selection, tolerance: 6) == .bottomRight)
    }

    @Test func hitTestingEdgesAlongTheirLength() {
        #expect(SelectionGeometry.handle(at: CGPoint(x: 140, y: 101), in: selection, tolerance: 6) == .top)
        #expect(SelectionGeometry.handle(at: CGPoint(x: 297, y: 120), in: selection, tolerance: 6) == .right)
    }

    @Test func hitTestingMisses() {
        #expect(SelectionGeometry.handle(at: CGPoint(x: 200, y: 150), in: selection, tolerance: 6) == nil)
        #expect(SelectionGeometry.handle(at: CGPoint(x: 500, y: 100), in: selection, tolerance: 6) == nil)
    }
}
