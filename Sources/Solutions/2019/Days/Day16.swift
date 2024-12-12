import Foundation
import Tools

final class Day16Solver: DaySolver {
	let dayNumber: Int = 16

	private var input: Input!

	private struct Input {
		let digits: [Int]
	}

	func solvePart1() -> String {
		// 0, 1, 0, -1
		var originalDigits = input.digits

		var oneRanges: [[Range<Int>]] = []
		var minusOneRanges: [[Range<Int>]] = []

		for digitIndex in 1 ... originalDigits.count {
			var currentOneRanges: [Range<Int>] = []
			var currentMinusOneRanges: [Range<Int>] = []

			var baseIndex = -1

			while true {
				let onesStartIndex = (1 * digitIndex) + baseIndex
				let onesEndIndex = min(onesStartIndex + digitIndex, originalDigits.count)

				if onesStartIndex >= originalDigits.count {
					break
				}

				currentOneRanges.append(onesStartIndex ..< onesEndIndex)

				let minusOnesStartIndex = (3 * digitIndex) + baseIndex
				let minusOnesEndIndex = min(minusOnesStartIndex + digitIndex, originalDigits.count)

				if minusOnesStartIndex >= originalDigits.count {
					break
				}

				currentMinusOneRanges.append(minusOnesStartIndex ..< minusOnesEndIndex)

				if minusOnesEndIndex >= originalDigits.count {
					break
				}

				baseIndex += digitIndex * 4
			}

			oneRanges.append(currentOneRanges)
			minusOneRanges.append(currentMinusOneRanges)
		}

		for _ in 0 ..< 100 {
			var newDigits = originalDigits

			for digitIndex in 0 ..< originalDigits.count {
				var onesSum = 0
				var minusSum = 0

				for range in oneRanges[digitIndex] {
					onesSum += originalDigits[range].reduce(0, +)
				}

				for range in minusOneRanges[digitIndex] {
					minusSum += originalDigits[range].reduce(0, +)
				}

				let result = abs(onesSum - minusSum) % 10

				newDigits[digitIndex] = result
			}

			originalDigits = newDigits
		}

		return originalDigits[0 ..< 8].map { String($0) }.joined()
	}

	func solvePart2() -> String {
		// solved with some help from: https://www.reddit.com/r/adventofcode/comments/ebf5cy/2019_day_16_part_2_understanding_how_to_come_up/

		let initialOffset = Int(input.digits[0 ..< 7].map { String($0) }.joined())!

		let totalDigitCount = input.digits.count * 10_000
		let length = totalDigitCount - initialOffset

		var digits: [Int] = []

		digits.reserveCapacity(length)

		let completeRepetitions = length / input.digits.count
		for _ in 0 ..< completeRepetitions {
			digits += input.digits
		}

		let remainingDigits = length % input.digits.count
		digits = Array(input.digits[input.digits.count - remainingDigits ..< input.digits.count]) + digits

		for _ in 0 ..< 100 {
			var sum = 0
			for digitIndex in (0 ..< digits.count).reversed() {
				sum += digits[digitIndex]

				digits[digitIndex] = sum % 10
			}
		}

		return digits[0 ..< 8].map { String($0) }.joined()
	}

	func parseInput(rawString: String) {
		let digits: [Int] = rawString.allLines().first!.compactMap { Int(String($0)) }

		input = .init(digits: digits)
	}
}
