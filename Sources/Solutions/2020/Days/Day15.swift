import Foundation
import Tools

final class Day15Solver: DaySolver {
	let dayNumber: Int = 15

	struct Input {
		let numbers: [Int]
	}

	func solvePart1(withInput input: Input) -> Int {
		var numbers: [Int] = input.numbers

		// brute force works fine here
		for _ in numbers.count ..< 2020 {
			let lastNumber = numbers.last!

			if let lastIndex = numbers[0 ..< numbers.count - 1].lastIndex(of: lastNumber) {
				numbers.append((numbers.count - 1) - lastIndex)
			} else {
				numbers.append(0)
			}
		}

		return numbers.last!
	}

	func solvePart2(withInput input: Input) -> Int {
		// memory hungry but efficient (< 1 sec)
		let roundCount = 30_000_000

		var lastNumberIndex: [Int] = Array(repeating: -1, count: roundCount)

		for (index, startNumber) in input.numbers.enumerated() {
			lastNumberIndex[startNumber] = index
		}

		var lastNumber = input.numbers.last!

		for round in input.numbers.count ..< roundCount {
			let lastIndex = lastNumberIndex[lastNumber]

			if lastIndex == round - 1 {
				lastNumberIndex[0] = lastNumberIndex[0] == -1 ? round : lastNumberIndex[0]

				lastNumber = 0
			} else {
				let newNumber = round - lastIndex - 1

				lastNumberIndex[lastNumber] = round - 1
				lastNumberIndex[newNumber] = lastNumberIndex[newNumber] == -1 ? round : lastNumberIndex[newNumber]

				lastNumber = newNumber
			}
		}

		return lastNumber
	}

	func parseInput(rawString: String) -> Input {
		let numbers = rawString.parseCommaSeparatedInts()

		return .init(numbers: numbers)
	}
}
