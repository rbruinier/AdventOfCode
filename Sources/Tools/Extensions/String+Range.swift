import Foundation

public extension String {
	subscript(_ offset: Int) -> String {
		String(self[index(startIndex, offsetBy: offset) ... index(startIndex, offsetBy: offset)])
	}

	subscript(range: Range<Int>) -> String {
		String(self[index(startIndex, offsetBy: range.lowerBound) ..< index(startIndex, offsetBy: range.upperBound)])
	}

	subscript(range: ClosedRange<Int>) -> String {
		String(self[index(startIndex, offsetBy: range.lowerBound) ... index(startIndex, offsetBy: range.upperBound)])
	}

	func ranges(of needle: String) -> [Range<Index>] {
		var ranges: [Range<Index>] = []

		var currentSearchRange: Range<Index> = startIndex ..< endIndex

		while let range = range(of: needle, options: [], range: currentSearchRange) {
			ranges.append(range)

			currentSearchRange = range.upperBound ..< endIndex
		}

		return ranges
	}
}
