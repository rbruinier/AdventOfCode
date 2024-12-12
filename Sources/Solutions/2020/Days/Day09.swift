import Foundation
import Tools

final class Day09Solver: DaySolver {
	let dayNumber: Int = 9

	private var input: Input!

	private struct Input {
		let numbers: [Int]
	}

	func solvePart1() -> Int {
		let scanSize = 25

		var window = Array(input.numbers[0 ..< scanSize])

		for number in input.numbers[scanSize ..< input.numbers.endIndex] {
			var isValid = false

			for aIndex in 0 ..< scanSize {
				for bIndex in aIndex + 1 ..< scanSize {
					if window[aIndex] + window[bIndex] == number {
						isValid = true

						break
					}
				}

				if isValid {
					break
				}
			}

			if isValid == false {
				return number
			}

			window.removeFirst()
			window.append(number)
		}

		return 0
	}

	func solvePart2() -> Int {
		let numbers = input.numbers
		let numberToFind = 556543474

		var sum = numbers[0] + numbers[1]

		var currentTailIndex = 0
		var currentHeadIndex = 1

		while true {
			if sum == numberToFind {
				let range = numbers[currentTailIndex ... currentHeadIndex]

				return range.min()! + range.max()!
			} else if sum < numberToFind {
				currentHeadIndex += 1

				sum += numbers[currentHeadIndex]
			} else {
				sum -= numbers[currentTailIndex]

				currentTailIndex += 1
			}

			guard currentHeadIndex < numbers.count, currentTailIndex < numbers.count else {
				return 0
			}
		}
	}

	func parseInput(rawString: String) {
		let numbers = rawString.allLines().compactMap { Int($0) }

		input = .init(numbers: numbers)
	}
}
