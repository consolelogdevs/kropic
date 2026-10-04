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
