import CoreGraphics
import KropicCore
import Observation

/// Selection state shared by the overlay views on every display.
/// Rects are display-local: points, origin top-left, y grows downward.
@MainActor
@Observable
final class SelectionModel {
    enum HitTarget: Equatable {
        case outside
        case inside
        case handle(SelectionHandle)
    }

    private enum Drag {
        case drawing(start: CGPoint)
        case moving(original: CGRect)
        case resizing(SelectionHandle, original: CGRect)
    }

    static let handleTolerance: CGFloat = 6
    static let minimumSize: CGFloat = 4

    private(set) var displayID: CGDirectDisplayID?
    private(set) var rect: CGRect?
    private(set) var isDragging = false
    private(set) var isMoving = false

    @ObservationIgnored private var drag: Drag?

    var canConfirm: Bool {
        guard let rect else { return false }
        return rect.width >= Self.minimumSize && rect.height >= Self.minimumSize
    }

    static let confirmButtonSize = CGSize(width: 32, height: 32)

    /// Where the confirm button sits on this display, or `nil` when it is hidden.
    func confirmButtonFrame(on displayID: CGDirectDisplayID, bounds: CGRect) -> CGRect? {
        guard let rect = rect(on: displayID), canConfirm, !isDragging else { return nil }
        return Placement.confirmButtonFrame(size: Self.confirmButtonSize, selection: rect, bounds: bounds, gap: 8)
    }

    func rect(on displayID: CGDirectDisplayID) -> CGRect? {
        self.displayID == displayID ? rect : nil
    }

    func hitTarget(at point: CGPoint, on displayID: CGDirectDisplayID) -> HitTarget {
        guard let rect = rect(on: displayID) else { return .outside }
        if let handle = SelectionGeometry.handle(at: point, in: rect, tolerance: Self.handleTolerance) {
            return .handle(handle)
        }
        return rect.contains(point) ? .inside : .outside
    }

    func dragChanged(on displayID: CGDirectDisplayID, bounds: CGRect, start: CGPoint, location: CGPoint, translation: CGSize) {
        if drag == nil {
            drag = beginDrag(on: displayID, at: start)
        }
        isDragging = true

        switch drag {
        case .drawing(let start):
            rect = SelectionGeometry.rect(from: start, to: location, within: bounds)
        case .moving(let original):
            isMoving = true
            rect = SelectionGeometry.moved(original, by: translation, within: bounds)
        case .resizing(let handle, let original):
            let anchor = SelectionGeometry.point(of: handle, in: original)
            let target = CGPoint(x: anchor.x + translation.width, y: anchor.y + translation.height)
            rect = SelectionGeometry.resized(original, handle: handle, to: target, within: bounds)
        case nil:
            break
        }
    }

    func dragEnded() {
        // A click without a real drag clears the selection.
        if case .drawing = drag, !canConfirm {
            rect = nil
            displayID = nil
        }
        drag = nil
        isDragging = false
        isMoving = false
    }

    private func beginDrag(on displayID: CGDirectDisplayID, at point: CGPoint) -> Drag {
        switch hitTarget(at: point, on: displayID) {
        case .handle(let handle):
            if let rect { return .resizing(handle, original: rect) }
        case .inside:
            if let rect { return .moving(original: rect) }
        case .outside:
            break
        }
        self.displayID = displayID
        rect = nil
        return .drawing(start: point)
    }
}
