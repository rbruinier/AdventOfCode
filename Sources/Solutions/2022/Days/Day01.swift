import Foundation
import Tools

final class Day01Solver: DaySolver {
	let dayNumber: Int = 1

	struct Input {
		let elves: [Elf]
	}

	struct Elf {
		var items: [Int]

		var total: Int {
			items.reduce(0, +)
		}
	}

	init() {}

	func solvePart1(withInput input: Input) -> Int {
		input.elves
			.sorted(by: { $0.total < $1.total })
			.last!
			.total
	}

	func solvePart2(withInput input: Input) -> Int {
		input.elves
			.sorted(by: { $0.total < $1.total })
			.suffix(3)
			.reduce(0) { $0 + $1.total }
	}

	func parseInput(rawString: String) -> Input {
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

		return .init(elves: elves)
	}
}
