import Foundation
import Tools

final class Day01Solver: DaySolver {
	let dayNumber: Int = 1

	struct Input {
		let digits: [Int]
	}

	func solvePart1(withInput input: Input) -> Int {
		var digits = input.digits

		digits.append(digits.first!)

		var sum = 0
		for i in 0 ..< (digits.count - 1) {
			sum += (digits[i] == digits[i + 1]) ? digits[i] : 0
		}

		return sum
	}

	func solvePart2(withInput input: Input) -> Int {
		let digits = input.digits

		let halfIndex = digits.count / 2

		var sum = 0
		for i in 0 ..< digits.count {
			sum += (digits[i] == digits[(i + halfIndex) % digits.count]) ? digits[i] : 0
		}

		return sum
	}

	func parseInput(rawString: String) -> Input {
		let digits: [Int] = rawString.allLines().first!.map {
			Int(String($0))!
		}

		return .init(digits: digits)
	}
}
