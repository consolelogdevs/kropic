import CoreGraphics
import Testing
@testable import KropicCore

struct AnnotationDocumentTests {
    private func box(_ x: CGFloat) -> Annotation {
        Annotation(kind: .rectangle(CGRect(x: x, y: 0, width: 10, height: 10)))
    }

    @Test func undoAndRedo() {
        var document = AnnotationDocument()
        let first = box(0), second = box(20)
        document.add(first)
        document.add(second)
        document.undo()
        #expect(document.annotations == [first])
        document.redo()
        #expect(document.annotations == [first, second])
    }

    @Test func newChangeClearsRedo() {
        var document = AnnotationDocument()
        document.add(box(0))
        document.undo()
        #expect(document.canRedo)
        document.add(box(20))
        #expect(!document.canRedo)
    }

    @Test func removeAllIsUndoable() {
        var document = AnnotationDocument()
        document.add(box(0))
        document.removeAll()
        #expect(document.isEmpty)
        document.undo()
        #expect(document.annotations.count == 1)
    }

    @Test func undoOnEmptyDoesNothing() {
        var document = AnnotationDocument()
        document.undo()
        #expect(document.isEmpty && !document.canUndo && !document.canRedo)
    }
}

struct AnnotationConversionTests {
    @Test func screenPointsBecomeImagePixels() {
        let annotation = Annotation(kind: .rectangle(CGRect(x: 110, y: 220, width: 50, height: 20)), lineWidth: 3)
        let converted = annotation.converted(origin: CGPoint(x: 100, y: 200), scale: 2)
        #expect(converted.kind == .rectangle(CGRect(x: 20, y: 40, width: 100, height: 40)))
        #expect(converted.lineWidth == 6)
        #expect(converted.id == annotation.id)
    }

    @Test func textScalesItsFont() {
        let annotation = Annotation(kind: .text("Hi", origin: CGPoint(x: 10, y: 10), fontSize: 18))
        #expect(annotation.converted(origin: .zero, scale: 2).kind == .text("Hi", origin: CGPoint(x: 20, y: 20), fontSize: 36))
    }

    @Test func arrowMovesBothEnds() {
        let annotation = Annotation(kind: .arrow(from: CGPoint(x: 5, y: 5), to: CGPoint(x: 15, y: 25)))
        #expect(annotation.converted(origin: CGPoint(x: 5, y: 5), scale: 1).kind == .arrow(from: .zero, to: CGPoint(x: 10, y: 20)))
    }
}
