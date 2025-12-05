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

		for range in input.freshRanges {
			// keep them sorted by lowerbound
			combinedRanges.sort(by: {
				$0.lowerBound < $1.lowerBound
			})

			// all ranges that are contained within this range should be removed first
			combinedRanges.removeAll(where: { $0.lowerBound > range.lowerBound && $0.upperBound < range.upperBound })

			let lowerBoundIndex = combinedRanges.firstIndex(where: { $0.contains(range.lowerBound) })
			let upperBoundIndex = combinedRanges.firstIndex(where: { $0.contains(range.upperBound) })

			switch (lowerBoundIndex, upperBoundIndex) {
			case (.none, .none):
				combinedRanges.append(range)
			case (.some(let lowerBoundIndex), .none):
				combinedRanges[lowerBoundIndex] = combinedRanges[lowerBoundIndex].lowerBound ... range.upperBound
			case (.none, .some(let upperBoundIndex)):
				combinedRanges[upperBoundIndex] = range.lowerBound ... combinedRanges[upperBoundIndex].upperBound
			case (.some(let lowerBoundIndex), .some(let upperBoundIndex)):
				if lowerBoundIndex != upperBoundIndex {
					combinedRanges[lowerBoundIndex] = combinedRanges[lowerBoundIndex].lowerBound ... combinedRanges[upperBoundIndex].upperBound
					combinedRanges.remove(at: upperBoundIndex)
				}
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
