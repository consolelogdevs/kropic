import AppKit
import SwiftUI

/// Design tokens that map to macOS semantic colors because the spec value is within a shade
/// of them (design/README.md). Every other token is a color set in the asset catalog and is
/// available as a generated symbol, e.g. `Color.panelBackground`.
extension Color {
    /// Header and footer lines, group borders. Spec: #E3E3E6 / #38383A.
    static let panelSeparator = Color(nsColor: .separatorColor)
    /// Text boxes, selects, secondary buttons. Spec: #FFFFFF / #1C1C1E.
    static let surface = Color(nsColor: .textBackgroundColor)
}
