import Foundation
import Tools

final class Day01Solver: DaySolver {
	let dayNumber: Int = 1

	struct Input {
		let line: String
	}

	func solvePart1(withInput input: Input) -> Int {
		input.line.filter { $0 == "(" }.count - input.line.filter { $0 == ")" }.count
	}

	func solvePart2(withInput input: Input) -> Int {
		var level = 0
		for (index, character) in input.line.enumerated() {
			if character == "(" {
				level += 1
			} else if character == ")" {
				level -= 1
			}

			if level == -1 {
				return index + 1
			}
		}

		return 0
	}

	func parseInput(rawString: String) -> Input {
		.init(line: rawString.trimmingCharacters(in: .whitespacesAndNewlines))
	}
}
