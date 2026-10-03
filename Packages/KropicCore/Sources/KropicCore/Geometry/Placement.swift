import CoreGraphics

/// Where to put things around a selection. All rects are display-local: origin top-left, y grows downward.
public enum Placement {
    /// Frame for the confirm button: below the selection's bottom-right corner, else above
    /// the selection's top-right corner, else inside the bottom-right corner.
    public static func confirmButtonFrame(size: CGSize, selection: CGRect, bounds: CGRect, gap: CGFloat) -> CGRect {
        let x = clamp(selection.maxX - size.width, min: bounds.minX, max: bounds.maxX - size.width)

        let below = selection.maxY + gap
        if below + size.height <= bounds.maxY {
            return CGRect(origin: CGPoint(x: x, y: below), size: size)
        }
        let above = selection.minY - gap - size.height
        if above >= bounds.minY {
            return CGRect(origin: CGPoint(x: x, y: above), size: size)
        }
        return CGRect(
            origin: CGPoint(x: selection.maxX - gap - size.width, y: selection.maxY - gap - size.height),
            size: size
        )
    }

    /// Frame for a panel next to the selection: right, else left, else below, else above.
    /// The result always lies inside `visible` as far as the panel's size allows.
    public static func panelFrame(size: CGSize, beside selection: CGRect, in visible: CGRect, gap: CGFloat) -> CGRect {
        let alignedY = clamp(selection.minY, min: visible.minY, max: visible.maxY - size.height)
        let alignedX = clamp(selection.minX, min: visible.minX, max: visible.maxX - size.width)

        let right = selection.maxX + gap
        if right + size.width <= visible.maxX {
            return CGRect(origin: CGPoint(x: right, y: alignedY), size: size)
        }
        let left = selection.minX - gap - size.width
        if left >= visible.minX {
            return CGRect(origin: CGPoint(x: left, y: alignedY), size: size)
        }
        let below = selection.maxY + gap
        if below + size.height <= visible.maxY {
            return CGRect(origin: CGPoint(x: alignedX, y: below), size: size)
        }
        let above = selection.minY - gap - size.height
        if above >= visible.minY {
            return CGRect(origin: CGPoint(x: alignedX, y: above), size: size)
        }
        // No free side: overlap the selection, pinned to the visible area's bottom-right.
        return CGRect(
            origin: CGPoint(
                x: clamp(visible.maxX - size.width, min: visible.minX, max: visible.maxX),
                y: clamp(visible.maxY - size.height, min: visible.minY, max: visible.maxY)
            ),
            size: size
        )
    }

    /// `size` scaled down (never up) so neither side exceeds `maxSide`, keeping the aspect ratio.
    public static func fitted(_ size: CGSize, maxSide: CGFloat) -> CGSize {
        let longest = max(size.width, size.height)
        guard longest > maxSide, longest > 0 else { return size }
        let factor = maxSide / longest
        return CGSize(width: size.width * factor, height: size.height * factor)
    }

    private static func clamp(_ value: CGFloat, min lower: CGFloat, max upper: CGFloat) -> CGFloat {
        Swift.max(lower, Swift.min(value, upper))
    }
}
