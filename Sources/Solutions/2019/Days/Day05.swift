import Foundation
import Tools

final class Day05Solver: DaySolver {
	let dayNumber: Int = 5

	struct Input {
		let program: [Int]
	}

	func solvePart1(withInput input: Input) -> Int {
		let intcode = IntcodeProcessor()

		let output = intcode.executeProgram(input.program, input: [1]).output

		return output.last!
	}

	func solvePart2(withInput input: Input) -> Int {
		let intcode = IntcodeProcessor()

		let output = intcode.executeProgram(input.program, input: [5]).output

		return output.last!
	}

	func parseInput(rawString: String) -> Input {
		.init(program: rawString.parseCommaSeparatedInts())
	}
}
