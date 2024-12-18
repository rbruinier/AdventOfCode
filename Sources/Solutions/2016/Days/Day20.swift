import Foundation
import Tools

final class Day20Solver: DaySolver {
	let dayNumber: Int = 20

	struct Input {
		let ranges: [ClosedRange<UInt32>]
	}

	// By collapsing all the ranges into continuous ranges we can much easier find the gaps between them
	private func collapseRanges(_ ranges: [ClosedRange<UInt32>]) -> [ClosedRange<UInt32>] {
		let sortedRanges = ranges.sorted(by: { lhs, rhs in
			lhs.lowerBound < rhs.lowerBound
		})

		var result: [ClosedRange<UInt32>] = []

		var currentRange = sortedRanges[0]

		for i in 1 ..< sortedRanges.count {
			let range = sortedRanges[i]

			let overlapRange = max(0, range.lowerBound - 1) ... range.upperBound

			if currentRange.overlaps(overlapRange) {
				currentRange = currentRange.lowerBound ... max(currentRange.upperBound, range.upperBound)
			} else {
				result.append(currentRange)

				currentRange = range
			}
		}

		if currentRange != result.last {
			result.append(currentRange)
		}

		return result
	}

	func solvePart1(withInput input: Input) -> Int {
		let ranges = collapseRanges(input.ranges)

		return Int(ranges[0].upperBound + 1)
	}

	func solvePart2(withInput input: Input) -> Int {
		let ranges = collapseRanges(input.ranges)

		var numberOfAvailableNumbers: UInt32 = 0

		for i in 1 ..< ranges.count {
			numberOfAvailableNumbers += (ranges[i].lowerBound - ranges[i - 1].upperBound) - 1
		}

		numberOfAvailableNumbers += UInt32.max - ranges.last!.upperBound

		return Int(numberOfAvailableNumbers)
	}

	func parseInput(rawString: String) -> Input {
		return .init(ranges: rawString.allLines().map {
			let components = $0.components(separatedBy: "-")

			return UInt32(components[0])! ... UInt32(components[1])!
		})
	}
}
