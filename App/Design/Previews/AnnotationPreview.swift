#if DEBUG
import KropicCore
import SwiftUI

/// The annotation editor with one of each mark on the sample capture.
struct AnnotationPreview: View {
    var body: some View {
        if let model {
            AnnotationEditorView(model: model)
        } else {
            Text(verbatim: "Preview image could not be drawn.")
        }
    }

    private var model: AnnotationEditorViewModel? {
        let text = "Opening hours have changed. From 1 November the library closes at 18:00 on weekdays and stays closed on Sundays.\n\nMembers can now borrow up to eight books at a time. Card number 4921 8830 1177."
        guard let image = ResultPreviews.sampleImage(text: text, size: CGSize(width: 560, height: 180)) else { return nil }
        let model = AnnotationEditorViewModel(image: image, scale: 2)
        model.setPreview(annotations: [
            Annotation(kind: .highlight(CGRect(x: 30, y: 52, width: 560, height: 40)), color: .yellow, lineWidth: 6),
            Annotation(kind: .rectangle(CGRect(x: 640, y: 18, width: 380, height: 84)), color: .red, lineWidth: 6),
            Annotation(kind: .arrow(from: CGPoint(x: 700, y: 300), to: CGPoint(x: 840, y: 112)), color: .red, lineWidth: 6),
            Annotation(kind: .pixelate(CGRect(x: 812, y: 130, width: 196, height: 46)), color: .red, lineWidth: 6),
            Annotation(kind: .blur(CGRect(x: 26, y: 130, width: 330, height: 46)), color: .red, lineWidth: 6),
            Annotation(kind: .text("New hours!", origin: CGPoint(x: 30, y: 230), fontSize: 36), color: .blue, lineWidth: 6),
        ], tool: .arrow)
        return model
    }
}
#endif
