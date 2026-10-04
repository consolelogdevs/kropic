import SwiftUI

/// Numbered steps in a grouped box, each row with a round accent badge.
struct OnboardingSteps: View {
    let steps: [String]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(spacing: 12) {
                    Text(verbatim: "\(index + 1)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.accent)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(Color.translationBackground))
                    Text(verbatim: step)
                        .font(.kropicBody)
                        .foregroundStyle(Color.textPrimary)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .frame(minHeight: 40)
                if index < steps.count - 1 {
                    Rectangle().fill(Color.rowSeparator).frame(height: 1)
                }
            }
        }
        .padding(.vertical, 4)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.groupBackground))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.panelSeparator))
    }
}
