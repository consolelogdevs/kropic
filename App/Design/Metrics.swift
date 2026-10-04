import CoreGraphics

/// Sizes and spacing from design/README.md, in points.
enum Metrics {
    /// 0.04 em at 11 pt.
    static let sectionLabelTracking: CGFloat = 0.44

    enum ResultPanel {
        static let width: CGFloat = 760
        static let designHeight: CGFloat = 440
        static let cornerRadius: CGFloat = 12
        static let headerHeight: CGFloat = 44
        static let headerLeadingPadding: CGFloat = 16
        static let headerTrailingPadding: CGFloat = 10
        static let footerHeight: CGFloat = 36
        static let footerPadding: CGFloat = 16
        static let contentPadding: CGFloat = 20
        static let leftColumnWidth: CGFloat = 264
        static let columnGap: CGFloat = 20
        static let rightColumnGap: CGFloat = 14
        static let iconButtonSize: CGFloat = 32
        static let iconSize: CGFloat = 15
    }

    enum Field {
        static let minHeight: CGFloat = 76
        static let cornerRadius: CGFloat = 8
        static let horizontalPadding: CGFloat = 12
        static let verticalPadding: CGFloat = 10
    }

    enum Select {
        static let height: CGFloat = 32
        static let cornerRadius: CGFloat = 7
    }

    enum Overlay {
        static let outlineWidth: CGFloat = 1.5
        static let handleSize: CGFloat = 8
        static let handleCornerRadius: CGFloat = 2
        static let sizeLabelHeight: CGFloat = 22
        static let sizeLabelCornerRadius: CGFloat = 6
        static let sizeLabelGap: CGFloat = 8
        static let barButtonSize: CGFloat = 32
        static let hintPillHeight: CGFloat = 34
    }
}
