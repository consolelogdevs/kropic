import KropicCore
import SwiftUI

/// The overlay content for one display: dim layer, selection chrome, confirm button and cursor.
/// Mouse dragging is handled by `SelectionOverlayPanel`, not by a SwiftUI gesture.
struct SelectionOverlayView: View {
    let model: SelectionModel
    let displayID: CGDirectDisplayID
    let onConfirm: () -> Void

    @State private var hoverTarget: SelectionModel.HitTarget = .outside

    var body: some View {
        GeometryReader { geometry in
            let bounds = CGRect(origin: .zero, size: geometry.size)

            ZStack(alignment: .topLeading) {
                SelectionChromeView(selection: model.rect(on: displayID), showsHandles: !model.isDragging)
                    .allowsHitTesting(false)

                Color.clear
                    .contentShape(Rectangle())
                    .onContinuousHover { phase in
                        if case .active(let location) = phase {
                            hoverTarget = model.hitTarget(at: location, on: displayID)
                        }
                    }
                    .pointerStyle(pointerStyle)

                if let frame = model.confirmButtonFrame(on: displayID, bounds: bounds) {
                    confirmButton
                        .position(x: frame.midX, y: frame.midY)
                }
            }
        }
        .ignoresSafeArea()
    }

    private var confirmButton: some View {
        Button(action: onConfirm) {
            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: SelectionModel.confirmButtonSize.width, height: SelectionModel.confirmButtonSize.height)
                .background(Circle().fill(Color.accentColor))
                .shadow(radius: 2)
        }
        .buttonStyle(.plain)
        .help("Capture (Return)")
    }

    private var pointerStyle: PointerStyle {
        switch hoverTarget {
        case .outside: .rectSelection
        case .inside: model.isMoving ? .grabActive : .grabIdle
        case .handle(let handle): .frameResize(position: handle.resizePosition)
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
