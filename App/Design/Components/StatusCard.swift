import SwiftUI

/// Warning notice with an icon, a bold title, a message and trailing actions,
/// e.g. the missing language pack.
struct StatusCard<Actions: View>: View {
    let systemImage: String
    let title: String
    let message: String
    @ViewBuilder let actions: () -> Actions

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.top, 1)
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: title)
                        .font(.system(size: 13, weight: .semibold))
                    Text(verbatim: message)
                        .font(.smallButton)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            HStack(spacing: 8) {
                Spacer()
                actions()
            }
        }
        .foregroundStyle(Color.warningText)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.warningBackground))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.warningBorder))
    }
}
