import KropicCore
import SwiftUI

extension AnnotationColor {
    var color: Color {
        Color(cgColor: cgColor())
    }

    var title: String {
        switch self {
        case .red: String(localized: "Red")
        case .yellow: String(localized: "Yellow")
        case .blue: String(localized: "Blue")
        case .black: String(localized: "Black")
        case .white: String(localized: "White")
        }
    }
}
