import KropicCore
import SwiftUI

/// Tools, colors and undo/redo above the canvas.
struct AnnotationToolbar: View {
    @Bindable var model: AnnotationEditorViewModel

    var body: some View {
        HStack(spacing: 12) {
            Picker("Tool", selection: $model.tool) {
                ForEach(AnnotationTool.allCases) { tool in
                    Image(systemName: tool.systemImage)
                        .help(tool.title)
                        .accessibilityLabel(tool.title)
                        .tag(tool)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .fixedSize()

            HStack(spacing: 6) {
                ForEach(AnnotationColor.allCases, id: \.self) { color in
                    Button {
                        model.color = color
                    } label: {
                        Circle()
                            .fill(color.color)
                            .overlay(Circle().strokeBorder(Color.controlBorder))
                            .frame(width: 18, height: 18)
                            .padding(3)
                            .overlay(Circle().strokeBorder(Color.accent, lineWidth: model.color == color ? 2 : 0))
                    }
                    .buttonStyle(.plain)
                    .help(color.title)
                    .accessibilityLabel(color.title)
                }
            }
            .disabled(!model.tool.usesColor)
            .opacity(model.tool.usesColor ? 1 : 0.35)

            Spacer()

            Button("Undo", systemImage: "arrow.uturn.backward", action: model.undo)
                .buttonStyle(IconButtonStyle())
                .keyboardShortcut("z", modifiers: .command)
                .disabled(!model.document.canUndo)
                .help("Undo")
            Button("Redo", systemImage: "arrow.uturn.forward", action: model.redo)
                .buttonStyle(IconButtonStyle())
                .keyboardShortcut("z", modifiers: [.command, .shift])
                .disabled(!model.document.canRedo)
                .help("Redo")
        }
        .padding(.horizontal, 16)
        .frame(height: Metrics.ResultPanel.headerHeight + 8)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.panelSeparator).frame(height: 1)
        }
    }
}
