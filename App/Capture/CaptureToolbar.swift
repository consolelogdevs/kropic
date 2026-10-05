import KropicCore
import SwiftUI

/// The dark bar under the selection: Move and the annotation tools, colors, undo and redo,
/// Copy, Save and Share, Translate, and cancel.
struct CaptureToolbar: View {
    @Bindable var annotations: OverlayAnnotations
    let onAction: (ToolbarAction) -> Void

    enum ToolbarAction {
        case copy, save, share, translate, cancel
    }

    var body: some View {
        HStack(spacing: 2) {
            toolButton(nil, systemImage: "cursorarrow", title: String(localized: "Move"), key: "V")
            ForEach(AnnotationTool.allCases) { tool in
                toolButton(tool, systemImage: tool.systemImage, title: tool.title, key: String(tool.shortcut).uppercased())
            }

            separator

            HStack(spacing: 2) {
                ForEach(AnnotationColor.allCases, id: \.self) { color in
                    Button {
                        annotations.color = color
                    } label: {
                        Circle()
                            .fill(color.color)
                            .overlay(Circle().strokeBorder(.white.opacity(0.35)))
                            .frame(width: 14, height: 14)
                            .padding(3)
                            .overlay(Circle().strokeBorder(.white, lineWidth: annotations.color == color ? 1.5 : 0))
                            .frame(width: 24, height: 32)
                            .contentShape(Rectangle())
                    }
                    .help(color.title)
                    .accessibilityLabel(color.title)
                }
            }
            .disabled(!(annotations.tool?.usesColor ?? true))
            .opacity((annotations.tool?.usesColor ?? true) ? 1 : 0.35)

            separator

            iconButton("Undo (⌘Z)", systemImage: "arrow.uturn.backward", action: annotations.undo)
                .disabled(!annotations.document.canUndo)
                .opacity(annotations.document.canUndo ? 1 : 0.35)
            iconButton("Redo (⇧⌘Z)", systemImage: "arrow.uturn.forward", action: annotations.redo)
                .disabled(!annotations.document.canRedo)
                .opacity(annotations.document.canRedo ? 1 : 0.35)

            separator

            iconButton("Copy Image (⌘C)", systemImage: "doc.on.doc") { onAction(.copy) }
            iconButton("Save Image… (⌘S)", systemImage: "square.and.arrow.down") { onAction(.save) }
            iconButton("Share Image…", systemImage: "square.and.arrow.up") { onAction(.share) }

            separator

            Button {
                onAction(.translate)
            } label: {
                Label("Translate", systemImage: "translate")
                    .font(.kropicBody.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .frame(height: Metrics.Overlay.barButtonSize)
                    .background(RoundedRectangle(cornerRadius: 7).fill(Color.accentFill))
            }
            .help("Translate (Return)")

            iconButton("Cancel (Esc)", systemImage: "xmark") { onAction(.cancel) }
        }
        .buttonStyle(.plain)
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.overlayChrome))
        .fixedSize()
    }

    private func toolButton(_ tool: AnnotationTool?, systemImage: String, title: String, key: String) -> some View {
        let isSelected = annotations.tool == tool
        return Button {
            annotations.tool = tool
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: Metrics.Overlay.barButtonSize, height: Metrics.Overlay.barButtonSize)
                .background(RoundedRectangle(cornerRadius: 7).fill(.white.opacity(isSelected ? 0.22 : 0)))
                .contentShape(Rectangle())
        }
        .help("\(title) (\(key))")
        .accessibilityLabel(title)
    }

    private func iconButton(_ help: LocalizedStringKey, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: Metrics.Overlay.barButtonSize, height: Metrics.Overlay.barButtonSize)
                .contentShape(Rectangle())
        }
        .help(help)
    }

    private var separator: some View {
        Rectangle()
            .fill(.white.opacity(0.2))
            .frame(width: 1, height: 20)
            .padding(.horizontal, 4)
    }
}
