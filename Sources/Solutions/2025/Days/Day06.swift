import Foundation
import Tools

final class Day06Solver: DaySolver {
	let dayNumber: Int = 6

	private var input: Input!

	enum Operation: String {
		case multiply = "*"
		case addition = "+"
	}

	struct Equation {
		let operands: [Int]
		let operation: Operation

		var result: Int {
			switch operation {
			case .multiply: operands.reduce(1, *)
			case .addition: operands.reduce(0, +)
			}
		}
	}

	struct Input {
		let operandLines: [String]
		let operationsLine: String
	}

	func solvePart1(withInput input: Input) -> Int {
		let equations = parseEquationsForPart1(input: input)

		return equations.map(\.result).reduce(0, +)
	}

	func solvePart2(withInput input: Input) -> Int {
		let equations = parseEquationsForPart2(input: input)

		return equations.map(\.result).reduce(0, +)
	}

	func parseEquationsForPart1(input: Input) -> [Equation] {
		let operands: [[Int]] = input.operandLines.map { line in
			line.split(separator: " ").compactMap { Int($0) }
		}

		let operations: [Operation] = input.operationsLine.split(separator: " ").compactMap { Operation(rawValue: String($0)) }

		var equations: [Equation] = []

		for x in 0 ..< operations.count {
			var equationOperands: [Int] = []

			for y in 0 ..< input.operandLines.count {
				equationOperands.append(operands[y][x])
			}

			equations.append(Equation(operands: equationOperands, operation: operations[x]))
		}

		return equations
	}

	func parseEquationsForPart2(input: Input) -> [Equation] {
		let operandLines = input.operandLines
		let operationsLine = input.operationsLine

		let maxLength = input.operandLines.map(\.count).max()!

		var equations: [Equation] = []

		var cursorPosition = 0

		while cursorPosition < maxLength {
			guard let operation = Operation(rawValue: operationsLine[cursorPosition]) else {
				break
			}

			let previousCursorPosition = cursorPosition

			cursorPosition += 1

			while cursorPosition < maxLength - 1, operationsLine[cursorPosition] == " " {
				cursorPosition += 1
			}

			var nrOfDigits = cursorPosition - previousCursorPosition - 1

			if cursorPosition == maxLength - 1 {
				nrOfDigits += 2
			}

			var operands: [Int] = []

			for digitIndex in 0 ..< nrOfDigits {
				var combinedDigits = ""

				for operandLine in operandLines {
					if operandLine[previousCursorPosition + digitIndex] != " " {
						combinedDigits += operandLine[previousCursorPosition + digitIndex]
					}
				}

				operands.append(Int(combinedDigits)!)
			}

			equations.append(Equation(operands: operands, operation: operation))
		}

		return equations
	}

	func parseInput(rawString: String) -> Input {
		let lines = rawString.allLines()

		let nrOfOperandLines = lines.count - 1

		return .init(operandLines: Array(lines[0 ..< nrOfOperandLines]), operationsLine: lines[nrOfOperandLines])
	}
}
