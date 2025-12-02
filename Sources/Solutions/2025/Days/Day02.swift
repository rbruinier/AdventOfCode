import Foundation
import Tools

final class Day02Solver: DaySolver {
	let dayNumber: Int = 2

	private var input: Input!

	struct Input {
		let ranges: [ClosedRange<Int>]
	}

	func solvePart1(withInput input: Input) -> Int {
		var sum = 0

		for range in input.ranges {
			for value in range where value >= 11 {
				let valueAsString = String(value)

				guard valueAsString.count % 2 == 0 else {
					continue
				}

				let halfwayIndex = valueAsString.count / 2

				if valueAsString[0 ..< halfwayIndex] == valueAsString[halfwayIndex ..< valueAsString.count] {
					sum += value
				}
			}
		}

		return sum
	}

	func solvePart2(withInput input: Input) -> Int {
		var sum = 0

		for range in input.ranges {
			for value in range where value >= 11 {
				let valueAsString = String(value)

				let halfwayIndex = valueAsString.count / 2

				lengthLoop: for length in 1 ... halfwayIndex where valueAsString.count % length == 0 {
					for index in stride(from: 0, to: valueAsString.count - length, by: length) {
						if valueAsString[index ..< index + length] != valueAsString[index + length ..< index + length * 2] {
							continue lengthLoop
						}
					}

					sum += value

					break lengthLoop
				}
			}
		}

		return sum
	}

	func parseInput(rawString: String) -> Input {
		let ranges: [ClosedRange<Int>] = rawString.allLines().first!.split(separator: ",").map { rangeAsString in
			let range = rangeAsString.split(separator: "-").map { Int($0)! }

			return range[0] ... range[1]
		}

		return .init(ranges: ranges)
	}
}
