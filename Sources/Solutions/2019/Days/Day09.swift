import Foundation
import Tools

final class Day09Solver: DaySolver {
	let dayNumber: Int = 9

	let expectedPart1Result = 2932210790
	let expectedPart2Result = 73144

	private var input: Input!

	private struct Input {
		let program: [Int]
	}

	func solvePart1() -> Int {
		let intcode = IntcodeProcessor()

		return intcode.executeProgram(input.program, input: [1]).output.first!
	}

	func solvePart2() -> Int {
		let intcode = IntcodeProcessor()

		return intcode.executeProgram(input.program, input: [2]).output.first!
	}

	func parseInput(rawString: String) {
		input = .init(program: rawString.parseCommaSeparatedInts())
	}
}
