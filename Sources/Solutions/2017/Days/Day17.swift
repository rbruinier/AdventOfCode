import Foundation
import Tools

/// For part 2 we don't need to actually keep the values in a buffer as we are only interested in whatever value was last put at position 1 (zero is always at position 0)
final class Day17Solver: DaySolver {
	let dayNumber: Int = 17

	struct Input {
		let steps: Int
	}

	func solvePart1(withInput input: Input) -> Int {
		var buffer = [0]

		var currentPosition = 0
		for i in 1 ... 2017 {
			currentPosition = ((currentPosition + input.steps) % buffer.count) + 1

			buffer.insert(i, at: currentPosition)
		}

		return buffer[(currentPosition + 1) % buffer.count]
	}

	func solvePart2(withInput input: Input) -> Int {
		var valueAfterZero = 0

		var currentPosition = 0
		for i in 1 ... 50_000_000 {
			currentPosition = ((currentPosition + input.steps) % i) + 1

			if currentPosition == 1 {
				valueAfterZero = i
			}
		}

		return valueAfterZero
	}

	func parseInput(rawString: String) -> Input {
		return .init(steps: 359)
	}
}
