import KropicCore
import SwiftUI

/// The overlay content for one display: dim layer, selection chrome, marks, capture toolbar,
/// hint and cursor. Mouse input is handled by `SelectionOverlayController` through the panel,
/// not by SwiftUI gestures; only the toolbar's buttons and the text field get clicks directly.
struct SelectionOverlayView: View {
    let model: SelectionModel
    @Bindable var annotations: OverlayAnnotations
    let displayID: CGDirectDisplayID
    let showsHint: Bool
    /// Height of the menu bar area at the top of this display.
    let hintTopInset: CGFloat
    let onAction: (CaptureToolbar.ToolbarAction) -> Void

    @State private var hoverTarget: SelectionModel.HitTarget = .outside
    @FocusState private var isTextFocused: Bool

    var body: some View {
        GeometryReader { geometry in
            let bounds = CGRect(origin: .zero, size: geometry.size)
            let selection = model.rect(on: displayID)

            ZStack(alignment: .topLeading) {
                SelectionChromeView(selection: selection, showsHandles: !model.isDragging && annotations.tool == nil)
                    .allowsHitTesting(false)

                if let selection {
                    marks
                        .frame(width: bounds.width, height: bounds.height, alignment: .topLeading)
                        .mask(Rectangle().frame(width: selection.width, height: selection.height).position(x: selection.midX, y: selection.midY))
                        .allowsHitTesting(false)
                    textField
                }

                Color.clear
                    .contentShape(Rectangle())
                    .onContinuousHover { phase in
                        if case .active(let location) = phase {
                            hoverTarget = model.hitTarget(at: location, on: displayID)
                        }
                    }
                    .pointerStyle(pointerStyle)
                    .allowsHitTesting(annotations.textDraft == nil)

                if showsHint {
                    SelectionHintPill()
                        .allowsHitTesting(false)
                        .frame(maxWidth: .infinity)
                        .padding(.top, hintTopInset + 12)
                }

                if let frame = model.toolbarFrame(on: displayID, bounds: bounds) {
                    CaptureToolbar(annotations: annotations, onAction: onAction)
                        .onGeometryChange(for: CGSize.self, of: { $0.size }) { model.toolbarSize = $0 }
                        .position(x: frame.midX, y: frame.midY)
                }
            }
        }
        .ignoresSafeArea()
        .onChange(of: annotations.textDraft != nil) { _, isEditing in
            isTextFocused = isEditing
        }
    }

    private var marks: some View {
        ZStack(alignment: .topLeading) {
            ForEach(annotations.annotations) { annotation in
                AnnotationShapeView(annotation: annotation)
            }
            if let draft = annotations.draft {
                AnnotationShapeView(annotation: draft)
            }
        }
    }

    @ViewBuilder
    private var textField: some View {
        if let draft = annotations.textDraft {
            TextField("Text", text: Binding(
                get: { annotations.textDraft?.text ?? "" },
                set: { annotations.textDraft?.text = $0 }
            ))
            .textFieldStyle(.plain)
            .font(.system(size: OverlayAnnotations.fontSize, weight: .bold))
            .foregroundStyle(annotations.color.color)
            .fixedSize()
            .padding(2)
            .background(RoundedRectangle(cornerRadius: 3).strokeBorder(.white, style: StrokeStyle(lineWidth: 1, dash: [3])))
            .offset(x: draft.origin.x - 2, y: draft.origin.y - 2)
            .focused($isTextFocused)
        }
    }

    private var pointerStyle: PointerStyle {
        if let tool = annotations.tool, hoverTarget == .inside {
            return tool == .text ? .horizontalText : .rectSelection
        }
        switch hoverTarget {
        case .outside: return .rectSelection
        case .inside: return model.isMoving ? .grabActive : .grabIdle
        case .handle(let handle): return .frameResize(position: handle.resizePosition)
        }
    }
}

private extension SelectionHandle {
    var resizePosition: FrameResizePosition {
        switch self {
        case .topLeft: .topLeading
        case .top: .top
        case .topRight: .topTrailing
        case .right: .trailing
        case .bottomRight: .bottomTrailing
        case .bottom: .bottom
        case .bottomLeft: .bottomLeading
        case .left: .leading
        }
    }
}
