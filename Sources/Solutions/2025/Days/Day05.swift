import Foundation
import Tools

final class Day05Solver: DaySolver {
	let dayNumber: Int = 5

	private var input: Input!

	struct Input {
		let freshRanges: [ClosedRange<Int>]
		let ids: [Int]
	}

	func solvePart1(withInput input: Input) -> Int {
		let freshRanges = input.freshRanges

		return input.ids.count(where: { id in
			freshRanges.contains(where: { $0.contains(id) })
		})
	}

	func solvePart2(withInput input: Input) -> Int {
		var combinedRanges: [ClosedRange<Int>] = []

		let sortedRanges = input.freshRanges.sorted(by: {
			$0.lowerBound < $1.lowerBound
		})

		for range in sortedRanges {
			if let last = combinedRanges.last, range.lowerBound <= last.upperBound {
				combinedRanges.removeLast()
				combinedRanges.append(last.lowerBound ... max(last.upperBound, range.upperBound))
			} else {
				combinedRanges.append(range)
			}
		}

		return combinedRanges.reduce(0) { result, item in
			result + item.count
		}
	}

	func parseInput(rawString: String) -> Input {
		var freshRanges: [ClosedRange<Int>] = []
		var ids: [Int] = []

		for line in rawString.allLines() {
			if line.firstIndex(of: "-") != nil {
				let components = line.components(separatedBy: "-")

				freshRanges.append(Int(components[0])! ... Int(components[1])!)
			} else {
				ids.append(Int(line)!)
			}
		}

		return .init(freshRanges: freshRanges, ids: ids)
	}
}
