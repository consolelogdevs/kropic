import CoreGraphics
import Foundation
import KropicCore
import ScreenCaptureKit

/// Captures part of a display with ScreenCaptureKit. The image is kept in memory only.
actor CaptureService {
    /// - Parameters:
    ///   - rect: Display-local points, origin at the display's top-left.
    func capture(_ rect: CGRect, on displayID: CGDirectDisplayID) async throws(CaptureError) -> CGImage {
        let content: SCShareableContent
        do {
            content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        } catch {
            throw Self.map(error)
        }

        guard let display = content.displays.first(where: { $0.displayID == displayID }) else {
            throw .displayNotFound
        }

        // Leave Kropic's own windows out so the overlay can never appear in the image.
        let ownProcessID = ProcessInfo.processInfo.processIdentifier
        let ownApps = content.applications.filter { $0.processID == ownProcessID }
        let filter = SCContentFilter(display: display, excludingApplications: ownApps, exceptingWindows: [])

        let configuration = SCStreamConfiguration()
        configuration.sourceRect = rect
        let pixels = ScreenGeometry.pixelSize(of: rect.size, scale: CGFloat(filter.pointPixelScale))
        configuration.width = pixels.width
        configuration.height = pixels.height
        configuration.captureResolution = .best
        configuration.showsCursor = false

        do {
            return try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: configuration)
        } catch {
            throw Self.map(error)
        }
    }

    private static func map(_ error: any Error) -> CaptureError {
        if let streamError = error as? SCStreamError, streamError.code == .userDeclined {
            return .permissionDenied
        }
        return .failed
    }
}
