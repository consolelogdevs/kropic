import KropicCore
import SwiftUI

/// The annotated image with the shape being drawn and the text being typed on top.
/// Drags are converted from view points to image pixels.
struct AnnotationCanvas: View {
    @Bindable var model: AnnotationEditorViewModel

    @FocusState private var isTextFocused: Bool

    var body: some View {
        let size = model.displaySize
        let factor = model.pixelsPerPoint

        Image(decorative: model.composite, scale: model.scale)
            .resizable()
            .interpolation(.high)
            .frame(width: size.width, height: size.height)
            .overlay(alignment: .topLeading) {
                if let draft = model.draft {
                    AnnotationDraftView(annotation: draft, pointsPerPixel: 1 / factor)
                        .allowsHitTesting(false)
                }
            }
            .overlay(alignment: .topLeading) { textField(factor: factor) }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        model.dragChanged(from: pixel(value.startLocation, factor), to: pixel(value.location, factor))
                    }
                    .onEnded { value in
                        model.dragEnded(from: pixel(value.startLocation, factor), to: pixel(value.location, factor))
                        isTextFocused = model.textDraft != nil
                    }
            )
            .pointerStyle(model.tool == .text ? .horizontalText : .rectSelection)
            .overlay(RoundedRectangle(cornerRadius: 2).strokeBorder(Color.controlBorder))
    }

    @ViewBuilder
    private func textField(factor: CGFloat) -> some View {
        if let draft = model.textDraft {
            TextField("Text", text: Binding(
                get: { model.textDraft?.text ?? "" },
                set: { model.textDraft?.text = $0 }
            ))
            .textFieldStyle(.plain)
            .font(.system(size: model.fontSize / factor, weight: .semibold))
            .foregroundStyle(model.color.color)
            .fixedSize()
            .padding(2)
            .background(RoundedRectangle(cornerRadius: 3).strokeBorder(Color.accent, style: StrokeStyle(lineWidth: 1, dash: [3])))
            .offset(x: draft.origin.x / factor - 2, y: draft.origin.y / factor - 2)
            .focused($isTextFocused)
            .onSubmit { model.commitText() }
        }
    }

    private func pixel(_ point: CGPoint, _ factor: CGFloat) -> CGPoint {
        let size = model.displaySize
        let clamped = CGPoint(x: min(max(point.x, 0), size.width), y: min(max(point.y, 0), size.height))
        return CGPoint(x: clamped.x * factor, y: clamped.y * factor)
    }
}
