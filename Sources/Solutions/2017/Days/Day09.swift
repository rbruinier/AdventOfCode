import Foundation
import Tools

final class Day09Solver: DaySolver {
	let dayNumber: Int = 9

	struct Input {
		let text: String
	}

	private func solve(text: String) -> (sum: Int, nrOfCancelled: Int) {
		var inGarbage = false
		var nextIsNegative = false

		var groupDepth = 0
		var sum = 0
		var nrOfCancelled = 0

		for character in input.text {
			if inGarbage {
				if character == ">" {
					if nextIsNegative {
						nextIsNegative = false

						continue
					} else {
						inGarbage = false
					}
				} else if character == "!" {
					nextIsNegative.toggle()
				} else {
					if !nextIsNegative {
						nrOfCancelled += 1
					}

					nextIsNegative = false
				}
			} else {
				if character == "{" {
					groupDepth += 1
				} else if character == "}" {
					sum += groupDepth

					groupDepth -= 1
				} else if character == "<" {
					inGarbage = true
					nextIsNegative = false
				}
			}
		}

		return (sum: sum, nrOfCancelled: nrOfCancelled)
	}

	func solvePart1(withInput input: Input) -> Int {
		solve(text: input.text).sum
	}

	func solvePart2(withInput input: Input) -> Int {
		solve(text: input.text).nrOfCancelled
	}

	func parseInput(rawString: String) -> Input {
		return .init(text: rawString.allLines().first!)
	}
}
