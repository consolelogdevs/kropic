import CoreGraphics
import Vision

/// Finds text in an image with Vision. Runs off the main actor.
public struct TextRecognizer: Sendable {
    public init() {}

    public func recognize(_ image: CGImage) async throws(OCRError) -> RecognizedText {
        var request = RecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.automaticallyDetectsLanguage = true

        let observations: [RecognizedTextObservation]
        do {
            observations = try await request.perform(on: image)
        } catch is CancellationError {
            throw .cancelled
        } catch {
            throw .failed
        }
        if Task.isCancelled {
            throw .cancelled
        }

        let lines = observations.compactMap { observation -> RecognizedLine? in
            guard let candidate = observation.topCandidates(1).first else { return nil }
            return RecognizedLine(
                text: candidate.string,
                confidence: candidate.confidence,
                bounds: observation.boundingBox.verticallyFlipped().cgRect
            )
        }
        return RecognizedText(lines: lines)
    }
}
