import Foundation
import Tools

/// In part 2 we detect the number of rounds the pattern repeats and after that we only have to perform the instructions the remainder amount of times.
final class Day16Solver: DaySolver {
	let dayNumber: Int = 16

	private var input: Input!

	private struct Input {
		let instructions: [Instruction]
	}

	private enum Instruction {
		case spin(size: Int)
		case swapByIndex(a: Int, b: Int)
		case swapByProgram(a: String, b: String)
	}

	private func generateStartLine() -> [String] {
		(0 ..< 16).map { String(asciiString: AsciiString([AsciiCharacter.a + $0])) }
	}

	private func shuffleLine(_ line: [String], instructions: [Instruction]) -> [String] {
		var line = line

		for instruction in instructions {
			switch instruction {
			case .spin(let size):
				line = Array(line[line.count - size ..< line.count] + line[0 ..< (line.count - size)])
			case .swapByIndex(let a, let b):
				line.swapAt(a, b)
			case .swapByProgram(let a, let b):
				line.swapAt(line.firstIndex(of: a)!, line.firstIndex(of: b)!)
			}
		}

		return line
	}

	func solvePart1() -> String {
		var line: [String] = generateStartLine()

		line = shuffleLine(line, instructions: input.instructions)

		return line.joined()
	}

	func solvePart2() -> String {
		let startLine: [String] = generateStartLine()

		var line = startLine

		// find repeating pattern
		var loopSize = 0
		while true {
			line = shuffleLine(line, instructions: input.instructions)

			loopSize += 1

			if line == startLine {
				break
			}
		}

		let remainderSteps = 1_000_000_000 % loopSize

		for _ in 0 ..< remainderSteps {
			line = shuffleLine(line, instructions: input.instructions)
		}

		return line.joined()
	}

	func parseInput(rawString: String) {
		input = .init(instructions: rawString.allLines().first!.components(separatedBy: ",").map { part in
			if let values = part.getCapturedValues(pattern: #"s([0-9]*)"#) {
				.spin(size: Int(values[0])!)
			} else if let values = part.getCapturedValues(pattern: #"x([0-9]*)\/([0-9]*)"#) {
				.swapByIndex(a: Int(values[0])!, b: Int(values[1])!)
			} else if let values = part.getCapturedValues(pattern: #"p([a-z]*)\/([a-z]*)"#) {
				.swapByProgram(a: values[0], b: values[1])
			} else {
				fatalError()
			}
		})
	}
}
