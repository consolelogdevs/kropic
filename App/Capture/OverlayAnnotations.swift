import CoreGraphics
import KropicCore
import Observation

/// Marks drawn on the selection in the overlay, in display-local points. Converted to image
/// pixels when the area is captured.
@MainActor
@Observable
final class OverlayAnnotations {
    struct TextDraft {
        var origin: CGPoint
        var text = ""
    }

    static let lineWidth: CGFloat = 3
    static let fontSize: CGFloat = 18
    private static let minimumDrag: CGFloat = 3

    /// `nil` is Move: drags move and resize the selection.
    var tool: AnnotationTool? {
        didSet { commitText() }
    }
    var color: AnnotationColor = .red
    private(set) var document = AnnotationDocument()
    private(set) var draft: Annotation?
    var textDraft: TextDraft?

    var annotations: [Annotation] { document.annotations }
    var isEditingText: Bool { textDraft != nil }

    /// Drawing happens inside `area` only; points outside are pulled to its edge.
    func dragChanged(from start: CGPoint, to end: CGPoint, in area: CGRect) {
        guard let tool, tool != .text else { return }
        draft = annotation(tool: tool, from: clamp(start, to: area), to: clamp(end, to: area))
    }

    func dragEnded(from start: CGPoint, to end: CGPoint, in area: CGRect) {
        draft = nil
        guard let tool else { return }
        let start = clamp(start, to: area), end = clamp(end, to: area)
        if tool == .text {
            commitText()
            textDraft = TextDraft(origin: end)
            return
        }
        guard hypot(end.x - start.x, end.y - start.y) >= Self.minimumDrag,
              let annotation = annotation(tool: tool, from: start, to: end)
        else { return }
        document.add(annotation)
    }

    func commitText() {
        guard let textDraft else { return }
        self.textDraft = nil
        let text = textDraft.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        document.add(Annotation(kind: .text(text, origin: textDraft.origin, fontSize: Self.fontSize), color: color, lineWidth: Self.lineWidth))
    }

    func cancelText() {
        textDraft = nil
    }

    func undo() {
        textDraft = nil
        document.undo()
    }

    func redo() {
        document.redo()
    }

    /// A new selection starts with no marks.
    func reset() {
        draft = nil
        textDraft = nil
        document = AnnotationDocument()
    }

    private func annotation(tool: AnnotationTool, from start: CGPoint, to end: CGPoint) -> Annotation? {
        let rect = CGRect(x: min(start.x, end.x), y: min(start.y, end.y), width: abs(end.x - start.x), height: abs(end.y - start.y))
        let kind: Annotation.Kind
        switch tool {
        case .arrow: kind = .arrow(from: start, to: end)
        case .rectangle: kind = .rectangle(rect)
        case .highlight: kind = .highlight(rect)
        case .blur: kind = .blur(rect)
        case .pixelate: kind = .pixelate(rect)
        case .text: return nil
        }
        return Annotation(kind: kind, color: color, lineWidth: Self.lineWidth)
    }

    private func clamp(_ point: CGPoint, to area: CGRect) -> CGPoint {
        CGPoint(x: min(max(point.x, area.minX), area.maxX), y: min(max(point.y, area.minY), area.maxY))
    }

    #if DEBUG
    func setPreview(_ annotations: [Annotation], tool: AnnotationTool?) {
        for annotation in annotations {
            document.add(annotation)
        }
        self.tool = tool
    }
    #endif
}
