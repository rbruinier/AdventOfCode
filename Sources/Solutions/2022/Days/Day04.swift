import Foundation
import Tools

final class Day04Solver: DaySolver {
	let dayNumber: Int = 4

	private var input: Input!

	private struct Input {
		let pairs: [Pair]
	}

	private struct Pair {
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

	func solvePart1() -> Int {
		input.pairs.count(\.hasFullyContainedRange)
	}

	func solvePart2() -> Int {
		input.pairs.count(\.hasOverlappingRange)
	}

	func parseInput(rawString: String) {
		input = .init(pairs: rawString.allLines().map { line in
			let elves = line.components(separatedBy: ",")

			let a = elves[0].components(separatedBy: "-")
			let b = elves[1].components(separatedBy: "-")

			return Pair(a: Int(a[0])! ... Int(a[1])!, b: Int(b[0])! ... Int(b[1])!)
		})
	}
}
