import Foundation
import Tools

final class Day01Solver: DaySolver {
	let dayNumber: Int = 1

	let expectedPart1Result = 381699
	let expectedPart2Result = 111605670

	private var input: Input!

	private struct Input {
		let numbers: [Int]
	}

	func solvePart1() -> Int {
		let numbers = input.numbers

		for i in 0 ..< numbers.count {
			for j in i + 1 ..< numbers.count {
				if numbers[i] + numbers[j] == 2020 {
					return numbers[i] * numbers[j]
				}
			}
		}

		return 0
	}

	func solvePart2() -> Int {
		let numbers = input.numbers

		for i in 0 ..< numbers.count {
			for j in i + 1 ..< numbers.count {
				for k in j + 1 ..< numbers.count {
					if numbers[i] + numbers[j] + numbers[k] == 2020 {
						return numbers[i] * numbers[j] * numbers[k]
					}
				}
			}
		}

		return 0
	}

	func parseInput(rawString: String) {
		let numbers = rawString.allLines().compactMap { Int($0) }

		input = .init(numbers: numbers)
	}
}
