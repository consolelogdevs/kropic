import CoreGraphics
import Testing
@testable import KropicCore

struct AnnotationGeometryTests {
    @Test func arrowHitsAlongItsLineOnly() {
        let arrow = Annotation(kind: .arrow(from: CGPoint(x: 0, y: 0), to: CGPoint(x: 100, y: 0)), lineWidth: 4)
        #expect(arrow.contains(CGPoint(x: 50, y: 3), tolerance: 4))
        #expect(!arrow.contains(CGPoint(x: 50, y: 20), tolerance: 4))
    }

    @Test func rectangleHitsItsOutlineNotItsMiddle() {
        let box = Annotation(kind: .rectangle(CGRect(x: 0, y: 0, width: 100, height: 100)), lineWidth: 4)
        #expect(box.contains(CGPoint(x: 1, y: 50), tolerance: 4))
        #expect(!box.contains(CGPoint(x: 50, y: 50), tolerance: 4))
    }

    @Test func filledAreasHitEverywhere() {
        let blur = Annotation(kind: .blur(CGRect(x: 0, y: 0, width: 100, height: 40)))
        #expect(blur.contains(CGPoint(x: 50, y: 20), tolerance: 2))
        #expect(!blur.contains(CGPoint(x: 50, y: 60), tolerance: 2))
    }

    @Test func penHitsNearItsStroke() {
        let pen = Annotation(kind: .pen([CGPoint(x: 0, y: 0), CGPoint(x: 50, y: 50), CGPoint(x: 100, y: 0)]), lineWidth: 4)
        #expect(pen.contains(CGPoint(x: 51, y: 49), tolerance: 4))
        #expect(!pen.contains(CGPoint(x: 50, y: 0), tolerance: 4))
    }

    @Test func textHasRealSize() {
        let text = Annotation(kind: .text("Hello", origin: CGPoint(x: 10, y: 10), fontSize: 20))
        #expect(text.bounds.width > 30 && text.bounds.height > 15)
        #expect(text.contains(CGPoint(x: 20, y: 20), tolerance: 0))
    }

    @Test func movedShiftsEveryPoint() {
        let pen = Annotation(kind: .pen([CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 10)]))
        #expect(pen.moved(by: CGSize(width: 5, height: -5)).kind == .pen([CGPoint(x: 5, y: -5), CGPoint(x: 15, y: 5)]))
        let box = Annotation(kind: .rectangle(CGRect(x: 0, y: 0, width: 10, height: 10)))
        #expect(box.moved(by: CGSize(width: 3, height: 4)).kind == .rectangle(CGRect(x: 3, y: 4, width: 10, height: 10)))
    }

    @Test func topmostPrefersTheLastDrawn() {
        let below = Annotation(kind: .highlight(CGRect(x: 0, y: 0, width: 100, height: 100)))
        let above = Annotation(kind: .blur(CGRect(x: 40, y: 40, width: 20, height: 20)))
        #expect([below, above].topmost(at: CGPoint(x: 50, y: 50), tolerance: 0)?.id == above.id)
        #expect([below, above].topmost(at: CGPoint(x: 10, y: 10), tolerance: 0)?.id == below.id)
    }
}
