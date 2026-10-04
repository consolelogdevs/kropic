import SwiftUI

/// Type roles from design/README.md. System font (SF Pro) throughout.
extension Font {
    /// Body text, inputs and buttons.
    static let kropicBody = Font.system(size: 13)
    /// Section labels such as "CAPTURED AREA". Use with `Metrics.sectionLabelTracking` and uppercase.
    static let sectionLabel = Font.system(size: 11, weight: .semibold)
    /// Small buttons ("Copy") and segmented pickers.
    static let smallButton = Font.system(size: 12)
    /// Captions, the language chip and the footer.
    static let kropicCaption = Font.system(size: 11)
    static let emptyStateTitle = Font.system(size: 15, weight: .semibold)
    static let onboardingTitle = Font.system(size: 20, weight: .semibold)
}
