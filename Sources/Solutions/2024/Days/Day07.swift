import Foundation
import Tools

final class Day07Solver: DaySolver {
	let dayNumber: Int = 7

	let expectedPart1Result = 975671981569
	let expectedPart2Result = 223472064194845

	private var input: Input!

	private struct Equation {
		let result: Int
		let operands: [Int]
	}

	private struct Input {
		let equations: [Equation]
	}

	private func solveEquation(expectedResult: Int, operands: [Int], currentValue: Int, allowConcatenation: Bool) -> Bool {
		guard let nextOperand = operands.first, currentValue <= expectedResult else {
			return expectedResult == currentValue
		}

		let newOperands = Array(operands[1...])

		if
			solveEquation(expectedResult: expectedResult, operands: newOperands, currentValue: currentValue + nextOperand, allowConcatenation: allowConcatenation)
			|| solveEquation(expectedResult: expectedResult, operands: newOperands, currentValue: currentValue * nextOperand, allowConcatenation: allowConcatenation)
		{
			return true
		}

		if allowConcatenation {
			let concatenatedValue = Int(String(currentValue) + String(nextOperand))!

			return solveEquation(expectedResult: expectedResult, operands: newOperands, currentValue: concatenatedValue, allowConcatenation: allowConcatenation)
		}

		return false
	}

	func solvePart1() -> Int {
		input.equations.filter {
			solveEquation(expectedResult: $0.result, operands: Array($0.operands[1...]), currentValue: $0.operands[0], allowConcatenation: false)
		}.map(\.result).reduce(0, +)
	}

	func solvePart2() -> Int {
		input.equations.filter {
			solveEquation(expectedResult: $0.result, operands: Array($0.operands[1...]), currentValue: $0.operands[0], allowConcatenation: true)
		}.map(\.result).reduce(0, +)
	}

	func parseInput(rawString: String) {
		input = .init(equations: rawString.allLines().map { line in
			let components = line.split(separator: ": ")

			return Equation(
				result: Int(components[0])!,
				operands: components[1].components(separatedBy: " ").map { Int($0)! }
			)
		})
	}
}
