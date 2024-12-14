import Foundation
import Tools

/// Hardcoded the input, couldn't be bothered to write a parser for such few instructions.
final class Day25Solver: DaySolver {
	let dayNumber: Int = 25

	struct Input {
		let beginState: State
		let steps: Int
		let instructions: [State: [Instruction]]
	}

	private enum Move {
		case left
		case right
	}

	private struct Instruction {
		let write: Int
		let move: Move
		let nextState: State
	}

	private enum State {
		case a
		case b
		case c
		case d
		case e
		case f
	}

	func solvePart1(withInput input: Input) -> Int {
		var state = input.beginState
		var cursorPosition = 0

		var values: [Int: Int] = [:]

		for _ in 0 ..< input.steps {
			let instruction: Instruction

			if values[cursorPosition, default: 0] == 0 {
				instruction = input.instructions[state]![0]
			} else {
				instruction = input.instructions[state]![1]
			}

			values[cursorPosition] = instruction.write

			cursorPosition += instruction.move == .right ? 1 : -1

			state = instruction.nextState
		}

		return values.values.filter { $0 == 1 }.count
	}

	func solvePart2(withInput input: Input) -> String {
		"Merry Christmas 🎄"
	}

	func parseInput(rawString: String) -> Input {
		//		// example input
		//        return .init(
		//			beginState: .a,
		//			steps: 6,
		//			instructions: [
		//				.a: [
		//					.init(write: 1, move: .right, nextState: .b),
		//					.init(write: 0, move: .left, nextState: .b),
		//				],
		//				.b: [
		//					.init(write: 1, move: .left, nextState: .a),
		//					.init(write: 1, move: .right, nextState: .a),
		//				]
		//			]
		//		)
//
		// real input
		return .init(
			beginState: .a,
			steps: 12861455,
			instructions: [
				.a: [
					.init(write: 1, move: .right, nextState: .b),
					.init(write: 0, move: .left, nextState: .b),
				],
				.b: [
					.init(write: 1, move: .left, nextState: .c),
					.init(write: 0, move: .right, nextState: .e),
				],
				.c: [
					.init(write: 1, move: .right, nextState: .e),
					.init(write: 0, move: .left, nextState: .d),
				],
				.d: [
					.init(write: 1, move: .left, nextState: .a),
					.init(write: 1, move: .left, nextState: .a),
				],
				.e: [
					.init(write: 0, move: .right, nextState: .a),
					.init(write: 0, move: .right, nextState: .f),
				],
				.f: [
					.init(write: 1, move: .right, nextState: .e),
					.init(write: 1, move: .right, nextState: .a),
				],
			]
		)
	}
}
