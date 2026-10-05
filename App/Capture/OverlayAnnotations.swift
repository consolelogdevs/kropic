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

    /// An in-memory picture of one display, taken when the overlay opens, used to show blur
    /// and pixelate exactly as they will look. Never saved.
    struct Snapshot {
        let image: CGImage
        /// Pixels per point.
        let scale: CGFloat
    }

    static let lineWidth: CGFloat = 3
    static let fontSize: CGFloat = 18
    /// How close to a mark a click has to be to select it, in points.
    static let hitTolerance: CGFloat = 5
    private static let minimumDrag: CGFloat = 3

    /// `nil` is Move: drags move marks, or move and resize the selection.
    var tool: AnnotationTool? {
        didSet {
            commitText()
            if tool != nil { selectedID = nil }
        }
    }
    var color: AnnotationColor = .red {
        didSet { recolorSelection() }
    }
    private(set) var document = AnnotationDocument()
    private(set) var draft: Annotation?
    private(set) var selectedID: Annotation.ID?
    private(set) var snapshots: [CGDirectDisplayID: Snapshot] = [:]
    var textDraft: TextDraft?

    @ObservationIgnored private var penPoints: [CGPoint] = []
    @ObservationIgnored private let draftID = Annotation.ID()
    @ObservationIgnored private var moving: (annotation: Annotation, offset: CGSize)?
    private var movingOffset: CGSize = .zero
    @ObservationIgnored private var previewCache: [Annotation.ID: (rect: CGRect, image: CGImage)] = [:]

    var isEditingText: Bool { textDraft != nil }

    /// The marks as they should appear now, including one being moved.
    var annotations: [Annotation] {
        guard let moving else { return document.annotations }
        return document.annotations.map { $0.id == moving.annotation.id ? $0.moved(by: movingOffset) : $0 }
    }

    var selected: Annotation? {
        annotations.first { $0.id == selectedID }
    }

    // MARK: Drawing

    /// Drawing happens inside `area` only; points outside are pulled to its edge.
    func dragChanged(from start: CGPoint, to end: CGPoint, in area: CGRect) {
        guard let tool, tool != .text else { return }
        let end = clamp(end, to: area)
        if tool == .pen {
            if penPoints.isEmpty { penPoints = [clamp(start, to: area)] }
            penPoints.append(end)
            draft = Annotation(id: draftID, kind: .pen(penPoints), color: color, lineWidth: Self.lineWidth)
            return
        }
        draft = annotation(tool: tool, from: clamp(start, to: area), to: end)
    }

    func dragEnded(from start: CGPoint, to end: CGPoint, in area: CGRect) {
        let points = penPoints
        penPoints = []
        draft = nil
        guard let tool else { return }
        let start = clamp(start, to: area), end = clamp(end, to: area)
        switch tool {
        case .text:
            commitText()
            textDraft = TextDraft(origin: end)
        case .pen:
            let stroke = points.isEmpty ? [start, end] : points
            document.add(Annotation(kind: .pen(stroke), color: color, lineWidth: Self.lineWidth))
        default:
            guard hypot(end.x - start.x, end.y - start.y) >= Self.minimumDrag,
                  var annotation = annotation(tool: tool, from: start, to: end)
            else { return }
            annotation.id = Annotation.ID()
            document.add(annotation)
        }
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

    // MARK: Selecting and moving (Move mode)

    /// Selects the topmost mark under `point` and starts moving it. Returns `false` when there
    /// is no mark there, which also clears the selection.
    func beginMove(at point: CGPoint) -> Bool {
        guard let mark = document.annotations.topmost(at: point, tolerance: Self.hitTolerance) else {
            selectedID = nil
            return false
        }
        selectedID = mark.id
        moving = (mark, .zero)
        movingOffset = .zero
        return true
    }

    func move(by offset: CGSize) {
        guard moving != nil else { return }
        movingOffset = offset
    }

    /// Ends a move as one undo step.
    func endMove() {
        guard let moving else { return }
        self.moving = nil
        let offset = movingOffset
        movingOffset = .zero
        document.update(moving.annotation.moved(by: offset))
    }

    func deleteSelection() {
        guard let selectedID else { return }
        document.remove(id: selectedID)
        self.selectedID = nil
    }

    // MARK: History

    func undo() {
        textDraft = nil
        selectedID = nil
        document.undo()
    }

    func redo() {
        selectedID = nil
        document.redo()
    }

    /// A new selection starts with no marks.
    func reset() {
        draft = nil
        textDraft = nil
        selectedID = nil
        penPoints = []
        document = AnnotationDocument()
    }

    // MARK: Blur and pixelate previews

    func setSnapshot(_ snapshot: Snapshot, for displayID: CGDirectDisplayID) {
        snapshots[displayID] = snapshot
    }

    /// The marked area of the screen snapshot with the real blur or pixelate applied, so the
    /// preview matches the captured image. `nil` until the snapshot is ready.
    func redactionPreview(for annotation: Annotation, on displayID: CGDirectDisplayID) -> (image: CGImage, scale: CGFloat)? {
        guard annotation.isRedaction, let snapshot = snapshots[displayID] else { return nil }
        let rect = annotation.bounds
        if let cached = previewCache[annotation.id], cached.rect == rect {
            return (cached.image, snapshot.scale)
        }
        let pixels = CGRect(x: rect.minX * snapshot.scale, y: rect.minY * snapshot.scale,
                            width: rect.width * snapshot.scale, height: rect.height * snapshot.scale).integral
        guard pixels.width >= 1, pixels.height >= 1, let crop = snapshot.image.cropping(to: pixels) else { return nil }
        var local = annotation
        let area = CGRect(x: 0, y: 0, width: crop.width, height: crop.height)
        if case .blur = annotation.kind {
            local.kind = .blur(area)
        } else {
            local.kind = .pixelate(area)
        }
        guard let image = AnnotationRenderer.render([local], onto: crop) else { return nil }
        previewCache[annotation.id] = (rect, image)
        return (image, snapshot.scale)
    }

    // MARK: Private

    private func recolorSelection() {
        guard var mark = selected, mark.color != color, !mark.isRedaction else { return }
        mark.color = color
        document.update(mark)
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
        case .text, .pen: return nil
        }
        return Annotation(id: draftID, kind: kind, color: color, lineWidth: Self.lineWidth)
    }

    private func clamp(_ point: CGPoint, to area: CGRect) -> CGPoint {
        CGPoint(x: min(max(point.x, area.minX), area.maxX), y: min(max(point.y, area.minY), area.maxY))
    }

    #if DEBUG
    func setPreview(_ annotations: [Annotation], tool: AnnotationTool?, selected: Annotation.ID? = nil) {
        for annotation in annotations {
            document.add(annotation)
        }
        self.tool = tool
        selectedID = selected
    }
    #endif
}
