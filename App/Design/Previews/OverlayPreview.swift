#if DEBUG
import KropicCore
import SwiftUI

/// The selection overlay over a stand-in desktop, with a few marks and the capture toolbar.
/// The desktop colors are sample content, not design tokens.
struct OverlayPreview: View {
    private static let screenSize = CGSize(width: 1440, height: 900)
    private static let selection = CGRect(x: 410, y: 300, width: 616, height: 170)

    var body: some View {
        ZStack(alignment: .topLeading) {
            desktop
            SelectionOverlayView(
                model: model,
                annotations: annotations,
                displayID: 1,
                showsHint: true,
                hintTopInset: 16,
                onAction: { _ in }
            )
            .environment(\.colorScheme, .light)
        }
        .frame(width: Self.screenSize.width, height: Self.screenSize.height)
    }

    private var model: SelectionModel {
        let model = SelectionModel()
        model.setPreview(displayID: 1, rect: Self.selection)
        return model
    }

    private var annotations: OverlayAnnotations {
        let annotations = OverlayAnnotations()
        let box = Annotation(kind: .rectangle(CGRect(x: 420, y: 330, width: 230, height: 34)), color: .red, lineWidth: 3)
        annotations.setPreview([
            box,
            Annotation(kind: .arrow(from: CGPoint(x: 760, y: 455), to: CGPoint(x: 660, y: 372)), color: .red, lineWidth: 3),
            Annotation(kind: .highlight(CGRect(x: 650, y: 400, width: 330, height: 26)), color: .yellow, lineWidth: 3),
            Annotation(kind: .pen(Self.squiggle), color: .blue, lineWidth: 3),
            Annotation(kind: .blur(CGRect(x: 420, y: 400, width: 225, height: 26)), lineWidth: 3),
            Annotation(kind: .pixelate(CGRect(x: 790, y: 330, width: 225, height: 34)), lineWidth: 3),
        ], tool: nil, selected: box.id)
        if let snapshot = ImageRenderer(content: desktop.frame(width: Self.screenSize.width, height: Self.screenSize.height)).cgImage {
            annotations.setSnapshot(.init(image: snapshot, scale: 1), for: 1)
        }
        return annotations
    }

    /// A hand-drawn underline under "Story time continues".
    private static let squiggle: [CGPoint] = stride(from: 0.0, through: 200, by: 8).map { x in
        CGPoint(x: 425 + x, y: 372 + 3 * sin(x / 12))
    }

    private var desktop: some View {
        ZStack(alignment: .topLeading) {
            Color(red: 0.24, green: 0.29, blue: 0.36)
            VStack(alignment: .leading, spacing: 22) {
                Text(verbatim: "Library News")
                    .font(.custom("Georgia", size: 32).weight(.bold))
                Text(verbatim: "Opening hours have changed. From 1 November the library closes at 18:00 on weekdays and stays closed on Sundays.")
                Text(verbatim: "The children's corner will move to the ground floor during renovation work. Story time continues every Saturday at 11:00.")
                Text(verbatim: "Members can now borrow up to eight books at a time. Returns are accepted at the front desk or through the drop box by the main entrance.")
            }
            .font(.custom("Georgia", size: 16))
            .lineSpacing(6)
            .foregroundStyle(Color(white: 0.1))
            .padding(.horizontal, 64)
            .padding(.top, 56)
            .frame(width: 720, height: 600, alignment: .topLeading)
            .background(RoundedRectangle(cornerRadius: 10).fill(.white))
            .offset(x: 360, y: 150)
        }
    }
}
#endif
