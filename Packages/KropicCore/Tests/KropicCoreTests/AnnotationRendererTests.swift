import CoreGraphics
import Testing
@testable import KropicCore

struct AnnotationRendererTests {
    @Test func keepsSizeAndLeavesOriginalUntouched() throws {
        let image = Pixels.white(width: 100, height: 60)
        let output = try #require(AnnotationRenderer.render([Annotation(kind: .rectangle(CGRect(x: 10, y: 10, width: 40, height: 30)))], onto: image))
        #expect(output.width == 100 && output.height == 60)
        #expect(Pixels(image).rgb(10, 10) == (255, 255, 255))
    }

    @Test func rectangleUsesTopLeftCoordinates() throws {
        let image = Pixels.white(width: 100, height: 60)
        let annotation = Annotation(kind: .rectangle(CGRect(x: 10, y: 5, width: 40, height: 20)), color: .red, lineWidth: 4)
        let pixels = Pixels(try #require(AnnotationRenderer.render([annotation], onto: image)))
        let (r, g, b) = pixels.rgb(30, 6)   // on the top edge, near y = 5
        #expect(r > 200 && g < 100 && b < 100)
        #expect(pixels.rgb(30, 15) == (255, 255, 255))   // inside stays white
        #expect(pixels.rgb(30, 54) == (255, 255, 255))   // the mirrored spot stays white
    }

    @Test func highlightTintsButKeepsContent() throws {
        let image = Pixels.white(width: 40, height: 40)
        let annotation = Annotation(kind: .highlight(CGRect(x: 0, y: 0, width: 40, height: 20)), color: .yellow)
        let pixels = Pixels(try #require(AnnotationRenderer.render([annotation], onto: image)))
        let (r, g, b) = pixels.rgb(20, 10)
        #expect(r > 240 && g > 200 && b < 200)
        #expect(pixels.rgb(20, 30) == (255, 255, 255))
    }

    @Test func pixelateMakesFlatBlocks() throws {
        let image = Pixels.stripes(width: 128, height: 64)
        let annotation = Annotation(kind: .pixelate(CGRect(x: 0, y: 0, width: 128, height: 64)))
        let pixels = Pixels(try #require(AnnotationRenderer.render([annotation], onto: image)))
        // Neighbouring pixels inside one block are identical, unlike the stripes below them.
        #expect(pixels.rgb(1, 1) == pixels.rgb(2, 1))
        #expect(pixels.rgb(1, 1) == pixels.rgb(1, 2))
    }

    @Test func blurRemovesFineDetail() throws {
        let image = Pixels.stripes(width: 120, height: 60)
        let annotation = Annotation(kind: .blur(CGRect(x: 0, y: 0, width: 120, height: 60)))
        let pixels = Pixels(try #require(AnnotationRenderer.render([annotation], onto: image)))
        // Stripes alternate between 0 and 255; after the blur neighbours are close to mid grey.
        let left = pixels.rgb(60, 30).0, right = pixels.rgb(61, 30).0
        #expect(abs(left - right) < 40)
        #expect(left > 60 && left < 200)
    }

    @Test func redactionOnlyAffectsItsArea() throws {
        let image = Pixels.stripes(width: 120, height: 60)
        let annotation = Annotation(kind: .pixelate(CGRect(x: 0, y: 0, width: 60, height: 60)))
        let pixels = Pixels(try #require(AnnotationRenderer.render([annotation], onto: image)))
        #expect(pixels.rgb(100, 30) != pixels.rgb(101, 30))   // stripes remain outside
    }

    @Test func arrowAndTextDraw() throws {
        let image = Pixels.white(width: 200, height: 100)
        let pixels = Pixels(try #require(AnnotationRenderer.render([
            Annotation(kind: .arrow(from: CGPoint(x: 10, y: 50), to: CGPoint(x: 150, y: 50)), color: .blue, lineWidth: 6),
            Annotation(kind: .text("Hi", origin: CGPoint(x: 10, y: 5), fontSize: 30), color: .black),
        ], onto: image)))
        let (r, _, b) = pixels.rgb(80, 50)
        #expect(b > 150 && r < 80)
        // Some pixel in the text's box is dark.
        let dark = (10..<60).contains { x in (5..<35).contains { y in pixels.rgb(x, y).0 < 100 } }
        #expect(dark)
    }

    @Test func penDrawsItsStroke() throws {
        let image = Pixels.white(width: 100, height: 100)
        let pen = Annotation(kind: .pen([CGPoint(x: 10, y: 10), CGPoint(x: 90, y: 90)]), color: .black, lineWidth: 6)
        let pixels = Pixels(try #require(AnnotationRenderer.render([pen], onto: image)))
        #expect(pixels.rgb(50, 50).0 < 60)
        #expect(pixels.rgb(80, 20) == (255, 255, 255))
    }
}
