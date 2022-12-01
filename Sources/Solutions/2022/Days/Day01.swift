import Foundation
import Tools

final class Day01Solver: DaySolver {
	let dayNumber: Int = 1

	private var input: Input!

	private struct Input {
		let elves: [Elf]
	}

	private struct Elf {
		var items: [Int]

		var total: Int {
			items.reduce(0, +)
		}
	}

	func solvePart1() -> Any {
		input.elves
			.sorted(by: { $0.total < $1.total })
			.last!
			.total
	}

	func solvePart2() -> Any {
		input.elves
			.sorted(by: { $0.total < $1.total })[input.elves.count - 3 ..< input.elves.count]
			.reduce(0) { $0 + $1.total }
	}

	func parseInput(rawString: String) {
		var elves: [Elf] = []

		var items: [Int] = []
		for line in rawString.allLines(includeEmpty: true) {
			if line.isEmpty {
				elves.append(.init(items: items))

				items.removeAll()
			} else {
				items.append(Int(line)!)
			}
		}

		if items.isNotEmpty {
			elves.append(.init(items: items))
		}

		input = .init(elves: elves)
	}
}
