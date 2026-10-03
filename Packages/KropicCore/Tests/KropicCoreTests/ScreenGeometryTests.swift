import CoreGraphics
import Testing
@testable import KropicCore

struct ScreenGeometryTests {
    // Primary MacBook display, 1512×982 points.
    let primary = CGRect(x: 0, y: 0, width: 1512, height: 982)
    // External display placed to the left and higher, so its origin is negative in x.
    let externalLeft = CGRect(x: -1920, y: 200, width: 1920, height: 1080)
    // External display placed above the primary one.
    let externalAbove = CGRect(x: 0, y: 982, width: 2560, height: 1440)

    @Test func convertsOnPrimaryDisplay() {
        // 100×50 rect whose top edge is 10 pt below the top of the screen.
        let global = CGRect(x: 20, y: 982 - 10 - 50, width: 100, height: 50)
        let local = ScreenGeometry.displayLocalRect(fromGlobal: global, displayFrame: primary)
        #expect(local == CGRect(x: 20, y: 10, width: 100, height: 50))
    }

    @Test func convertsOnDisplayWithNegativeOrigin() {
        let global = CGRect(x: -1900, y: 200 + 1080 - 30 - 40, width: 300, height: 40)
        let local = ScreenGeometry.displayLocalRect(fromGlobal: global, displayFrame: externalLeft)
        #expect(local == CGRect(x: 20, y: 30, width: 300, height: 40))
    }

    @Test func convertsOnDisplayAbovePrimary() {
        let global = CGRect(x: 100, y: 982 + 1440 - 5 - 20, width: 60, height: 20)
        let local = ScreenGeometry.displayLocalRect(fromGlobal: global, displayFrame: externalAbove)
        #expect(local == CGRect(x: 100, y: 5, width: 60, height: 20))
    }

    @Test(arguments: [
        CGRect(x: 0, y: 0, width: 1512, height: 982),
        CGRect(x: -1920, y: 200, width: 1920, height: 1080),
        CGRect(x: 0, y: 982, width: 2560, height: 1440),
    ])
    func roundTrips(displayFrame: CGRect) {
        let local = CGRect(x: 12.5, y: 40, width: 200, height: 75.5)
        let global = ScreenGeometry.globalRect(fromDisplayLocal: local, displayFrame: displayFrame)
        #expect(ScreenGeometry.displayLocalRect(fromGlobal: global, displayFrame: displayFrame) == local)
    }

    @Test func pixelSizeOnRetina() {
        #expect(ScreenGeometry.pixelSize(of: CGSize(width: 100.5, height: 40), scale: 2) == PixelSize(width: 201, height: 80))
    }

    @Test func pixelSizeOnNonRetina() {
        #expect(ScreenGeometry.pixelSize(of: CGSize(width: 300, height: 120), scale: 1) == PixelSize(width: 300, height: 120))
    }
}
