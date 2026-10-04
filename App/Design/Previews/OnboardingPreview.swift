#if DEBUG
import SwiftUI

/// The onboarding window's content with a stand-in for the transparent title bar.
struct OnboardingPreview: View {
    var body: some View {
        VStack(spacing: 0) {
            Color.panelBackground.frame(height: 38)
            OnboardingView(permissions: PermissionService()) {}
        }
        .frame(width: 560)
    }
}
#endif
