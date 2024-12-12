import Foundation
import Tools

final class Day06Solver: DaySolver {
	let dayNumber: Int = 6

	private var input: Input!

	private struct Input {
		let strings: [String]
	}

	func solvePart1() -> String {
		let length = input.strings.first!.count

		var result = ""
		for index in 0 ..< length {
			result += input.strings.map { $0[index] }.mostCommonElement!
		}

		return result
	}

	func solvePart2() -> String {
		let length = input.strings.first!.count

		var result = ""
		for index in 0 ..< length {
			result += input.strings.map { $0[index] }.leastCommonElement!
		}

		return result
	}

	func parseInput(rawString: String) {
		input = .init(strings: rawString.allLines())
	}
}
