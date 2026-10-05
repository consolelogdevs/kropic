/// The drawing tools in the annotation editor.
enum AnnotationTool: String, CaseIterable, Identifiable {
    case arrow, rectangle, text, highlight, blur, pixelate

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .arrow: "arrow.up.right"
        case .rectangle: "rectangle"
        case .text: "textformat"
        case .highlight: "highlighter"
        case .blur: "drop.halffull"
        case .pixelate: "squareshape.split.3x3"
        }
    }

    var title: String {
        switch self {
        case .arrow: String(localized: "Arrow")
        case .rectangle: String(localized: "Rectangle")
        case .text: String(localized: "Text")
        case .highlight: String(localized: "Highlight")
        case .blur: String(localized: "Blur")
        case .pixelate: String(localized: "Pixelate")
        }
    }

    /// Single-key shortcut in the capture toolbar.
    var shortcut: Character {
        switch self {
        case .arrow: "a"
        case .rectangle: "r"
        case .text: "t"
        case .highlight: "h"
        case .blur: "b"
        case .pixelate: "p"
        }
    }

    /// Blur and pixelate hide content and have no color.
    var usesColor: Bool {
        self != .blur && self != .pixelate
    }
}
