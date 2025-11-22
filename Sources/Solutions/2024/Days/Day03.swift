import Foundation
import RegexBuilder
import Tools

final class Day03Solver: DaySolver {
	let dayNumber: Int = 3

	struct Input {
		let memory: String
	}

	func solve(memory: String, allowEnabling: Bool) -> Int {
		let doRegex = Regex { "do()" }
		let dontRegex = Regex { "don't()" }
		let mulRegex = Regex {
			"mul("
			Capture { OneOrMore(.digit) } transform: { Int($0)! }
			","
			Capture { OneOrMore(.digit) } transform: { Int($0)! }
			")"
		}

		let regex = Regex {
			ChoiceOf {
				doRegex
				dontRegex
				mulRegex
			}
		}

		var isEnabled = true
		var total = 0

		for match in memory.matches(of: regex) {
			let operation = match.output.0

			if operation.firstMatch(of: doRegex) != nil {
				isEnabled = true
			} else if operation.firstMatch(of: dontRegex) != nil {
				isEnabled = !allowEnabling || false
			} else if let mul = operation.firstMatch(of: mulRegex), isEnabled {
				total += mul.1 * mul.2
			}
		}

		return total
	}

	func solvePart1(withInput input: Input) -> Int {
		solve(memory: input.memory, allowEnabling: false)
	}

	func solvePart2(withInput input: Input) -> Int {
		solve(memory: input.memory, allowEnabling: true)
	}

	func parseInput(rawString: String) -> Input {
		.init(memory: rawString.trimmingCharacters(in: .whitespacesAndNewlines))
	}
}
