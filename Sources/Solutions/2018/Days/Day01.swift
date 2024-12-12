import Foundation
import Tools

final class Day01Solver: DaySolver {
	let dayNumber: Int = 1

	private var input: Input!

	private struct Input {
		let frequencies: [Int]
	}

	func solvePart1() -> Int {
		input.frequencies.reduce(0, +)
	}

	func solvePart2() -> Int {
		var frequencies: Set<Int> = []

		var frequency = 0
		while true {
			for value in input.frequencies {
				frequency += value

				if frequencies.contains(frequency) {
					return frequency
				}

				frequencies.insert(frequency)
			}
		}
	}

	func parseInput(rawString: String) {
		input = .init(frequencies: rawString.allLines().map { Int($0)! })
	}
}
