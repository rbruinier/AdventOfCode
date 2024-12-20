import Collections
import Foundation
import Tools

final class Day10Solver: DaySolver {
	let dayNumber: Int = 10

	struct Input {
		let string: String
	}

	private func runAlgorithm(on numbers: [Int]) -> [Int] {
		var currentDigit = numbers[0]
		var currentCount = 1

		var newNumbers: [Int] = []

		newNumbers.reserveCapacity(numbers.count * 2)

		for digit in numbers[1 ..< numbers.count] {
			if digit != currentDigit {
				newNumbers.append(currentCount)
				newNumbers.append(currentDigit)

				currentDigit = digit
				currentCount = 1
			} else {
				currentCount += 1
			}
		}

		newNumbers.append(currentCount)
		newNumbers.append(currentDigit)

		return newNumbers
	}

	private var cachedCurrentNumbers: [Int]!

	func solvePart1(withInput input: Input) -> Int {
		var currentNumbers: [Int] = input.string.map { Int(String($0))! }

		for _ in 0 ..< 40 {
			currentNumbers = runAlgorithm(on: currentNumbers)
		}

		cachedCurrentNumbers = currentNumbers

		return currentNumbers.count
	}

	func solvePart2(withInput input: Input) -> Int {
		var currentNumbers = cachedCurrentNumbers!

		for _ in 40 ..< 50 {
			currentNumbers = runAlgorithm(on: currentNumbers)
		}

		return currentNumbers.count
	}

	func parseInput(rawString: String) -> Input {
		return .init(string: rawString.allLines().first!)
	}
}
