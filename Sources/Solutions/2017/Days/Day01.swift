import Foundation
import Tools

final class Day01Solver: DaySolver {
	let dayNumber: Int = 1

	private var input: Input!

	private struct Input {
		let digits: [Int]
	}

	func solvePart1() -> Int {
		var digits = input.digits

		digits.append(digits.first!)

		var sum = 0
		for i in 0 ..< (digits.count - 1) {
			sum += (digits[i] == digits[i + 1]) ? digits[i] : 0
		}

		return sum
	}

	func solvePart2() -> Int {
		let digits = input.digits

		let halfIndex = digits.count / 2

		var sum = 0
		for i in 0 ..< digits.count {
			sum += (digits[i] == digits[(i + halfIndex) % digits.count]) ? digits[i] : 0
		}

		return sum
	}

	func parseInput(rawString: String) {
		let digits: [Int] = rawString.allLines().first!.map {
			Int(String($0))!
		}

		input = .init(digits: digits)
	}
}
