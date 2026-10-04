#if DEBUG
import SwiftUI

/// The selection overlay over a stand-in desktop, like the Overlay artboard (1440 × 900).
/// The desktop colors are sample content, not design tokens.
struct OverlayPreview: View {
    private static let screenSize = CGSize(width: 1440, height: 900)
    private static let selection = CGRect(x: 410, y: 310, width: 616, height: 72)

    var body: some View {
        ZStack(alignment: .topLeading) {
            desktop
            SelectionOverlayView(
                model: model,
                displayID: 1,
                showsHint: true,
                hintTopInset: 16,
                onConfirm: {},
                onCancel: {}
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
