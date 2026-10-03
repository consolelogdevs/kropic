import CoreGraphics

/// Rebuilds plain text from recognized lines.
///
/// Pieces at the same height form a row and are joined left to right with a space.
/// Rows are ordered top to bottom. A vertical gap larger than `paragraphGapRatio`
/// times the typical line height becomes a blank line, so paragraphs survive.
/// Side-by-side columns are not detected and will be interleaved row by row.
public enum TextLayout {
    static let paragraphGapRatio: CGFloat = 0.8

    public static func text(from lines: [RecognizedLine]) -> String {
        let rows = self.rows(from: lines.filter { !$0.text.isEmpty })
        guard !rows.isEmpty else { return "" }

        let lineHeight = medianHeight(of: rows)
        var output = ""
        for (index, row) in rows.enumerated() {
            if index > 0 {
                let gap = row.bounds.minY - rows[index - 1].bounds.maxY
                output += gap > lineHeight * paragraphGapRatio ? "\n\n" : "\n"
            }
            output += row.text
        }
        return output
    }

    private struct Row {
        var pieces: [RecognizedLine]
        var bounds: CGRect

        var text: String {
            pieces.sorted { $0.bounds.minX < $1.bounds.minX }.map(\.text).joined(separator: " ")
        }
    }

    private static func rows(from lines: [RecognizedLine]) -> [Row] {
        var rows: [Row] = []
        for line in lines.sorted(by: { $0.bounds.minY < $1.bounds.minY }) {
            if let last = rows.indices.last, sharesRow(line.bounds, rows[last].bounds) {
                rows[last].pieces.append(line)
                rows[last].bounds = rows[last].bounds.union(line.bounds)
            } else {
                rows.append(Row(pieces: [line], bounds: line.bounds))
            }
        }
        return rows
    }

    /// Two boxes share a row when they overlap vertically by more than half the smaller height.
    private static func sharesRow(_ a: CGRect, _ b: CGRect) -> Bool {
        let overlap = min(a.maxY, b.maxY) - max(a.minY, b.minY)
        return overlap > min(a.height, b.height) / 2
    }

    private static func medianHeight(of rows: [Row]) -> CGFloat {
        let heights = rows.flatMap { $0.pieces.map(\.bounds.height) }.sorted()
        return heights[heights.count / 2]
    }
}
