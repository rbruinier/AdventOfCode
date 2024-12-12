import Foundation
import Tools

final class Day21Solver: DaySolver {
	let dayNumber: Int = 21

	private var input: Input!

	private struct Input {
		let password: AsciiString
		let scrambledPassword: AsciiString
		let operations: [Operation]
	}

	private enum Operation {
		case swapPosition(x: Int, positionY: Int) // swap position 6 with position 3
		case swapLetter(x: AsciiCharacter, letterY: AsciiCharacter) // swap letter g with letter b
		case rotateLeft(steps: Int) // rotate left 2 steps
		case rotateRight(steps: Int) // rotate right 6 steps
		case rotate(basedOnLetter: AsciiCharacter) // rotate based on position of letter e
		case reverse(fromPosition: Int, toPosition: Int) // reverse positions 3 through 7
		case move(fromPosition: Int, toPosition: Int) // move position 2 to position 6
	}

	private func rotateLeft(_ value: AsciiString, steps: Int) -> AsciiString {
		var result = value

		for _ in 0 ..< steps {
			result = AsciiString(result[1 ..< result.count]) + AsciiString(result[0 ..< 1])
		}

		return result
	}

	private func rotateRight(_ value: AsciiString, steps: Int) -> AsciiString {
		var result = value
		let offset = result.count - 1

		for _ in 0 ..< steps {
			result = AsciiString(result[offset ..< result.count]) + AsciiString(result[0 ..< offset])
		}

		return result
	}

	private func performOperations(_ operations: [Operation], on originalPassword: AsciiString) -> AsciiString {
		var password = originalPassword

		for operation in operations {
			switch operation {
			case .swapPosition(let positionX, let positionY):
				password.swapAt(positionX, positionY)
			case .swapLetter(let letterX, let letterY):
				let positionX = password.firstIndex(of: letterX)!
				let positionY = password.firstIndex(of: letterY)!

				password.swapAt(positionX, positionY)
			case .rotateLeft(let steps):
				password = rotateLeft(password, steps: steps)
			case .rotateRight(let steps):
				password = rotateRight(password, steps: steps)
			case .rotate(let basedOnLetter):
				let index = password.firstIndex(of: basedOnLetter)!
				let steps = 1 + index + (index >= 4 ? 1 : 0)

				password = rotateRight(password, steps: steps)
			case .reverse(let from, let through):
				password = AsciiString(password[0 ..< from])
					+ AsciiString(password[from ... through].reversed())
					+ AsciiString(password[through + 1 ..< password.count])
			case .move(let fromPosition, let toPosition):
				password.insert(password.remove(at: fromPosition), at: toPosition)
			}
		}

		return password
	}

	private func performReversedOperations(_ operations: [Operation], on originalPassword: AsciiString) -> AsciiString {
		var password = originalPassword

		for operation in operations {
			switch operation {
			case .swapPosition(let positionX, let positionY):
				password.swapAt(positionX, positionY)
			case .swapLetter(let letterX, let letterY):
				let positionX = password.firstIndex(of: letterX)!
				let positionY = password.firstIndex(of: letterY)!

				password.swapAt(positionX, positionY)
			case .rotateLeft(let steps):
				password = rotateRight(password, steps: steps)
			case .rotateRight(let steps):
				password = rotateLeft(password, steps: steps)
			case .rotate(let basedOnLetter):
				// some reverse engineering, if we take a look at the original operation the end positions are unique for each position:
				//
				// POS:    0 1 2 3 4 5 6 7
				// SHR:    1 2 3 4 6 7 8 9
				// ENDPOS: 1 3 5 7 2 4 6 0
				//
				// so we take the end position and map it back to the original position by rotating the right steps

				let index = password.firstIndex(of: basedOnLetter)!

				switch index {
				case 1:
					password = rotateLeft(password, steps: 1)
				case 3:
					password = rotateLeft(password, steps: 2)
				case 5:
					password = rotateLeft(password, steps: 3)
				case 7:
					password = rotateLeft(password, steps: 4)
				case 2:
					password = rotateRight(password, steps: 2)
				case 4:
					password = rotateRight(password, steps: 1)
				case 6:
					break
				case 0:
					password = rotateLeft(password, steps: 1)
				default:
					fatalError()
				}
			case .reverse(let from, let through):
				password = AsciiString(password[0 ..< from])
					+ AsciiString(password[from ... through].reversed())
					+ AsciiString(password[through + 1 ..< password.count])
			case .move(let fromPosition, let toPosition):
				password.insert(password.remove(at: toPosition), at: fromPosition)
			}
		}

		return password
	}

	func solvePart1() -> String {
		performOperations(input.operations, on: input.password).description
	}

	func solvePart2() -> String {
		performReversedOperations(input.operations.reversed(), on: input.scrambledPassword).description
	}

	func parseInput(rawString: String) {
		let operations: [Operation] = rawString.allLines().map { line in
			if let arguments = line.getCapturedValues(pattern: #"swap position ([0-9]*) with position ([0-9]*)"#) {
				.swapPosition(x: Int(arguments[0])!, positionY: Int(arguments[1])!)
			} else if let arguments = line.getCapturedValues(pattern: #"swap letter ([a-z]) with letter ([a-z])"#) {
				.swapLetter(x: AsciiCharacter(arguments[0])!, letterY: AsciiCharacter(arguments[1])!)
			} else if let arguments = line.getCapturedValues(pattern: #"rotate left ([0-9]*) steps"#) {
				.rotateLeft(steps: Int(arguments[0])!)
			} else if let arguments = line.getCapturedValues(pattern: #"rotate left ([0-9]*) step"#) {
				.rotateLeft(steps: Int(arguments[0])!)
			} else if let arguments = line.getCapturedValues(pattern: #"rotate right ([0-9]*) steps"#) {
				.rotateRight(steps: Int(arguments[0])!)
			} else if let arguments = line.getCapturedValues(pattern: #"rotate right ([0-9]*) step"#) {
				.rotateRight(steps: Int(arguments[0])!)
			} else if let arguments = line.getCapturedValues(pattern: #"rotate based on position of letter ([a-zA-Z]*)"#) {
				.rotate(basedOnLetter: AsciiCharacter(arguments[0])!)
			} else if let arguments = line.getCapturedValues(pattern: #"reverse positions ([0-9]*) through ([0-9]*)"#) {
				.reverse(fromPosition: Int(arguments[0])!, toPosition: Int(arguments[1])!)
			} else if let arguments = line.getCapturedValues(pattern: #"move position ([0-9]*) to position ([0-9]*)"#) {
				.move(fromPosition: Int(arguments[0])!, toPosition: Int(arguments[1])!)
			} else {
				fatalError()
			}
		}

		input = .init(
			password: AsciiString(string: "abcdefgh"),
			scrambledPassword: AsciiString(string: "fbgdceah"),
			operations: operations
		)
	}
}
