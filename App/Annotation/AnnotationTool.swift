/// The drawing tools on the capture toolbar.
enum AnnotationTool: String, CaseIterable, Identifiable {
    case pen, arrow, rectangle, text, highlight, blur, pixelate

    var id: String { rawValue }

    /// SF Symbol for tools whose icon is a symbol; highlight, blur and pixelate draw their own.
    var systemImage: String {
        switch self {
        case .pen: "pencil.line"
        case .arrow: "arrow.up.right"
        case .rectangle: "rectangle"
        case .text: "textformat"
        case .highlight: "highlighter"
        case .blur: "circle.fill"
        case .pixelate: "square.grid.3x3"
        }
    }

    var title: String {
        switch self {
        case .pen: String(localized: "Pencil")
        case .arrow: String(localized: "Arrow")
        case .rectangle: String(localized: "Rectangle")
        case .text: String(localized: "Text")
        case .highlight: String(localized: "Highlighter")
        case .blur: String(localized: "Blur")
        case .pixelate: String(localized: "Pixelate")
        }
    }

    /// What the tool does, for the hint pill while it is selected.
    var hint: String {
        switch self {
        case .pen: String(localized: "Pencil: draw freely")
        case .arrow: String(localized: "Arrow: drag from start to tip")
        case .rectangle: String(localized: "Rectangle: drag to frame something")
        case .text: String(localized: "Text: click to type, Enter to finish")
        case .highlight: String(localized: "Highlighter: drag over text to mark it")
        case .blur: String(localized: "Blur: drag over text to hide it")
        case .pixelate: String(localized: "Pixelate: drag over text to hide it")
        }
    }

    /// Single-key shortcut in the capture toolbar.
    var shortcut: Character {
        switch self {
        case .pen: "d"
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
