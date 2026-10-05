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

    /// Replaces the annotation with the same id, e.g. after it was moved or recolored.
    public mutating func update(_ annotation: Annotation) {
        guard let index = annotations.firstIndex(where: { $0.id == annotation.id }),
              annotations[index] != annotation
        else { return }
        record()
        annotations[index] = annotation
    }

    public mutating func remove(id: Annotation.ID) {
        guard let index = annotations.firstIndex(where: { $0.id == id }) else { return }
        record()
        annotations.remove(at: index)
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
