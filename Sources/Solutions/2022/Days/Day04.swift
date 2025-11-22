import Foundation
import Tools

final class Day04Solver: DaySolver {
	let dayNumber: Int = 4

	struct Input {
		let pairs: [Pair]
	}

	struct Pair {
		let a: ClosedRange<Int>
		let b: ClosedRange<Int>

		var hasFullyContainedRange: Bool {
			a.contains(b) || b.contains(a)
		}

		var hasOverlappingRange: Bool {
			a.overlaps(b) || b.overlaps(a)
		}
	}

	init() {}

	func solvePart1(withInput input: Input) -> Int {
		input.pairs.count(\.hasFullyContainedRange)
	}

	func solvePart2(withInput input: Input) -> Int {
		input.pairs.count(\.hasOverlappingRange)
	}

	func parseInput(rawString: String) -> Input {
		.init(pairs: rawString.allLines().map { line in
			let elves = line.components(separatedBy: ",")

			let a = elves[0].components(separatedBy: "-")
			let b = elves[1].components(separatedBy: "-")

			return Pair(a: Int(a[0])! ... Int(a[1])!, b: Int(b[0])! ... Int(b[1])!)
		})
	}
}
