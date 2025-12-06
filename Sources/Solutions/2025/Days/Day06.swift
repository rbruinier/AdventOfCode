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

		var currentOperands: [Int] = []

		for cursorIndex in (0 ..< maxLength).reversed() {
			let operandAsString = operandLines.map { $0[cursorIndex] }.filter { $0 != " " }.joined()

			if let operand = Int(operandAsString) {
				currentOperands.append(operand)
			}

			if let operation = Operation(rawValue: operationsLine[cursorIndex]) {
				equations.append(Equation(operands: currentOperands, operation: operation))

				currentOperands = []
			}
		}

		return equations
	}

	func parseInput(rawString: String) -> Input {
		let lines = rawString.allLines()

		let nrOfOperandLines = lines.count - 1

		return .init(operandLines: Array(lines[0 ..< nrOfOperandLines]), operationsLine: lines[nrOfOperandLines])
	}
}
