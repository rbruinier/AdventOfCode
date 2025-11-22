import Foundation
import Tools

final class Day09Solver: DaySolver {
	let dayNumber: Int = 9

	struct Input {
		let program: [Int]
	}

	func solvePart1(withInput input: Input) -> Int {
		let intcode = IntcodeProcessor()

		return intcode.executeProgram(input.program, input: [1]).output.first!
	}

	func solvePart2(withInput input: Input) -> Int {
		let intcode = IntcodeProcessor()

		return intcode.executeProgram(input.program, input: [2]).output.first!
	}

	func parseInput(rawString: String) -> Input {
		.init(program: rawString.parseCommaSeparatedInts())
	}
}
