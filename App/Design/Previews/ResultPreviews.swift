#if DEBUG
import AppKit
import SwiftUI

/// The result panel in the four states from the spec, with the spec's sample content.
@MainActor
enum ResultPreviews {
    static let languages = ["en", "tr", "de", "ja"].map { Locale.Language(identifier: $0) }

    static var main: some View {
        let model = makeModel(sampleText: english, size: CGSize(width: 412, height: 96))
        model.setPreview(state: .recognized, text: english)
        model.translation.setPreview(languages: languages, detected: language("en"), target: language("tr"), state: .translated(turkish))
        return view(model)
    }

    static var loading: some View {
        let model = makeModel(sampleText: english, size: CGSize(width: 412, height: 96))
        model.translation.setPreview(languages: languages, detected: nil, target: language("tr"), state: .idle)
        return view(model)
    }

    static var noText: some View {
        let model = makeModel(sampleText: nil, size: CGSize(width: 188, height: 120))
        model.setPreview(state: .noText, text: "")
        model.translation.setPreview(languages: languages, detected: nil, target: language("tr"), state: .idle)
        return view(model)
    }

    static var languagePack: some View {
        let model = makeModel(sampleText: japanese, size: CGSize(width: 412, height: 96))
        model.setPreview(state: .recognized, text: japanese)
        model.translation.setPreview(languages: languages, detected: language("ja"), target: language("tr"), state: .needsDownload)
        return view(model)
    }

    private static let english = "Opening hours have changed. From 1 November the library closes at 18:00 on weekdays and stays closed on Sundays."
    private static let turkish = "Çalışma saatleri değişti. 1 Kasım'dan itibaren kütüphane hafta içi 18:00'de kapanıyor ve pazar günleri kapalı."
    private static let japanese = "営業時間が変更されました。11月1日から図書館は平日18時に閉館し、日曜日は休館となります。"

    private static func language(_ identifier: String) -> Locale.Language {
        Locale.Language(identifier: identifier)
    }

    private static func view(_ model: ResultViewModel) -> some View {
        ResultView(model: model, onCaptureAgain: {}, onClose: {})
    }

    private static func makeModel(sampleText: String?, size: CGSize) -> ResultViewModel {
        let settings = AppSettings(defaults: UserDefaults(suiteName: "KropicPreviews") ?? .standard)
        guard let image = sampleImage(text: sampleText, size: size) else {
            return ResultViewModel(captureFailure: "Preview image could not be drawn.", selectionSize: size, settings: settings)
        }
        return ResultViewModel(image: image, scale: 2, selectionSize: size, settings: settings)
    }

    /// A stand-in for a captured image: text on white like the spec's sample, or a grey photo.
    private static func sampleImage(text: String?, size: CGSize) -> CGImage? {
        let scale: CGFloat = 2
        let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil, pixelsWide: Int(size.width * scale), pixelsHigh: Int(size.height * scale),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
        )
        guard let rep, let context = NSGraphicsContext(bitmapImageRep: rep) else { return nil }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        context.cgContext.scaleBy(x: scale, y: scale)
        if let text {
            NSColor.white.setFill()
            CGRect(origin: .zero, size: size).fill()
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 4
            let font = NSFont(name: "Georgia", size: 13) ?? .systemFont(ofSize: 13)
            NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: NSColor(white: 0.17, alpha: 1), .paragraphStyle: paragraph])
                .draw(in: CGRect(x: 16, y: 10, width: size.width - 32, height: size.height - 24))
        } else {
            NSGradient(starting: NSColor(white: 0.55, alpha: 1), ending: NSColor(white: 0.8, alpha: 1))?
                .draw(in: CGRect(origin: .zero, size: size), angle: 60)
        }
        NSGraphicsContext.restoreGraphicsState()
        return rep.cgImage
    }
}
#endif
