import AppKit
import KropicCore
import Observation
import SwiftUI

/// State of the annotation editor for one captured image. Everything stays in memory.
@MainActor
@Observable
final class AnnotationEditorViewModel {
    /// A text annotation being typed, at an image-pixel position.
    struct TextDraft {
        var origin: CGPoint
        var text = ""
    }

    /// The editor shows the image at most this large, in points.
    static let maxDisplaySize = CGSize(width: 960, height: 640)
    /// Drags shorter than this (in pixels) are treated as clicks and add nothing.
    private static let minimumDrag: CGFloat = 4

    let image: CGImage
    /// Pixels per point of the captured image.
    let scale: CGFloat
    private(set) var document = AnnotationDocument()
    /// The image with all committed annotations drawn in.
    private(set) var composite: CGImage
    private(set) var draft: Annotation?
    var textDraft: TextDraft?
    var tool: AnnotationTool = .arrow {
        didSet { commitText() }
    }
    var color: AnnotationColor = .red
    private(set) var didCopy = false

    @ObservationIgnored private var copyResetTask: Task<Void, Never>?

    init(image: CGImage, scale: CGFloat) {
        self.image = image
        self.scale = max(scale, 1)
        composite = image
    }

    var lineWidth: CGFloat { 3 * scale }
    var fontSize: CGFloat { 18 * scale }

    /// The image's size in points, scaled down to fit the editor.
    var displaySize: CGSize {
        let points = CGSize(width: CGFloat(image.width) / scale, height: CGFloat(image.height) / scale)
        let factor = min(1, Self.maxDisplaySize.width / points.width, Self.maxDisplaySize.height / points.height)
        return CGSize(width: points.width * factor, height: points.height * factor)
    }

    /// Image pixels per displayed point.
    var pixelsPerPoint: CGFloat {
        CGFloat(image.width) / displaySize.width
    }

    // MARK: Drawing, in image pixels

    func dragChanged(from start: CGPoint, to end: CGPoint) {
        guard tool != .text else { return }
        draft = annotation(from: start, to: end)
    }

    func dragEnded(from start: CGPoint, to end: CGPoint) {
        draft = nil
        if tool == .text {
            commitText()
            textDraft = TextDraft(origin: end)
            return
        }
        guard hypot(end.x - start.x, end.y - start.y) >= Self.minimumDrag,
              let annotation = annotation(from: start, to: end)
        else { return }
        add(annotation)
    }

    func commitText() {
        guard let textDraft else { return }
        self.textDraft = nil
        let text = textDraft.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        add(Annotation(kind: .text(text, origin: textDraft.origin, fontSize: fontSize), color: color, lineWidth: lineWidth))
    }

    func undo() {
        textDraft = nil
        document.undo()
        refresh()
    }

    func redo() {
        document.redo()
        refresh()
    }

    func clear() {
        textDraft = nil
        document.removeAll()
        refresh()
    }

    // MARK: Output

    /// The annotated image for sharing, at its real point size.
    var shareImage: Image {
        Image(decorative: composite, scale: scale)
    }

    func copyImage() {
        commitText()
        let size = NSSize(width: CGFloat(composite.width) / scale, height: CGFloat(composite.height) / scale)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([NSImage(cgImage: composite, size: size)])
        didCopy = true
        copyResetTask?.cancel()
        copyResetTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1.5))
            guard !Task.isCancelled else { return }
            self?.didCopy = false
        }
    }

    // MARK: Private

    private func add(_ annotation: Annotation) {
        document.add(annotation)
        refresh()
    }

    private func refresh() {
        composite = AnnotationRenderer.render(document.annotations, onto: image) ?? image
    }

    private func annotation(from start: CGPoint, to end: CGPoint) -> Annotation? {
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
        return Annotation(kind: kind, color: color, lineWidth: lineWidth)
    }

    #if DEBUG
    func setPreview(annotations: [Annotation], tool: AnnotationTool) {
        for annotation in annotations {
            document.add(annotation)
        }
        self.tool = tool
        refresh()
    }
    #endif
}
