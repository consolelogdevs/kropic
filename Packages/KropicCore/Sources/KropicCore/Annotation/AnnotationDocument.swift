/// The annotations on one image, with undo and redo.
public struct AnnotationDocument: Sendable, Equatable {
    public private(set) var annotations: [Annotation] = []
    private var undoStack: [[Annotation]] = []
    private var redoStack: [[Annotation]] = []

    public init() {}

    public var canUndo: Bool { !undoStack.isEmpty }
    public var canRedo: Bool { !redoStack.isEmpty }
    public var isEmpty: Bool { annotations.isEmpty }

    public mutating func add(_ annotation: Annotation) {
        record()
        annotations.append(annotation)
    }

    public mutating func removeAll() {
        guard !annotations.isEmpty else { return }
        record()
        annotations.removeAll()
    }

    public mutating func undo() {
        guard let previous = undoStack.popLast() else { return }
        redoStack.append(annotations)
        annotations = previous
    }

    public mutating func redo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(annotations)
        annotations = next
    }

    /// Any new change starts a new branch, so redo no longer applies.
    private mutating func record() {
        undoStack.append(annotations)
        redoStack.removeAll()
    }
}
