import SwiftUI

extension View {
    /// Lets buttons and pop-up pickers stretch to the width they are offered, like the spec's
    /// full-width selects. The modifier exists from macOS 26; earlier versions keep the
    /// native intrinsic width.
    @ViewBuilder
    func flexibleButtonSizing() -> some View {
        if #available(macOS 26.0, *) {
            buttonSizing(.flexible)
        } else {
            self
        }
    }
}
