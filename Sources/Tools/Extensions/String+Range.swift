import Foundation

extension String {
    public subscript(range: Range<Int>) -> String {
        return String(self[index(startIndex, offsetBy: range.lowerBound) ..< index(startIndex, offsetBy: range.upperBound)])
    }


    public subscript(range: ClosedRange<Int>) -> String {
        return String(self[index(startIndex, offsetBy: range.lowerBound) ... index(startIndex, offsetBy: range.upperBound)])
    }

    public func ranges(of needle: String) -> [Range<Index>] {
        var ranges: [Range<Index>] = []

        var currentSearchRange: Range<Index> = self.startIndex ..< self.endIndex

        while let range = self.range(of: needle, options: [], range: currentSearchRange) {
            ranges.append(range)

            currentSearchRange = range.upperBound ..< self.endIndex
        }

        return ranges
    }
}
