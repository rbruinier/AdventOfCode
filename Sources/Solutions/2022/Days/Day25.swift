import Foundation
import Tools

final class Day25Solver: DaySolver {
	let dayNumber: Int = 25

	private var input: Input!

	private struct Input {
		let numbers: [String]
	}

	init() {}

	private func snafuToInt(_ snafu: String) -> Int {
		var result = 0

		for digit in snafu {
			result *= 5

			switch digit {
			case "0": result += 0
			case "1": result += 1
			case "2": result += 2
			case "-": result -= 1
			case "=": result -= 2
			default: fatalError()
			}
		}

		return result
	}

	private func intToSnafu(_ number: Int) -> String {
		var result = ""

		var number = number

		while number > 0 {
			switch number % 5 {
			case 0:
				result = "0" + result
			case 1:
				result = "1" + result
				number -= 1
			case 2:
				result = "2" + result
				number -= 2
			case 3:
				result = "=" + result
				number += 2
			case 4:
				result = "-" + result
				number += 1
			default: fatalError()
			}

			number /= 5
		}

		return result
	}

	func solvePart1() -> String {
		let sum = input.numbers.map { snafuToInt($0) }.reduce(0, +)

		return intToSnafu(sum)
	}

	func solvePart2() -> String {
		"Merry Christmas 🎄"
	}

	func parseInput(rawString: String) {
		input = .init(numbers: rawString.allLines())
	}
}
