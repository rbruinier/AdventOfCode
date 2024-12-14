import Foundation
import Tools

final class Day11Solver: DaySolver {
	let dayNumber: Int = 11

	struct Input {
		let stones: [Int]
	}

	private static func performCount(with stones: [Int], numberOfCycles: Int) -> Int {
		var stoneCounters: [Int: Int] = [:]

		for stone in stones {
			stoneCounters[stone, default: 0] += 1
		}

		for _ in 0 ..< numberOfCycles {
			var newStoneCounters: [Int: Int] = [:]

			for (stone, count) in stoneCounters {
				if stone == 0 {
					newStoneCounters[1, default: 0] += count
				} else {
					let asString = String(stone)

					if asString.count % 2 == 0 {
						let half = asString.count / 2

						let left = Int(asString[0 ..< half])!
						let right = Int(asString[half ..< asString.count])!

						newStoneCounters[left, default: 0] += count
						newStoneCounters[right, default: 0] += count
					} else {
						newStoneCounters[stone * 2024, default: 0] += count
					}
				}
			}

			stoneCounters = newStoneCounters
		}

		return stoneCounters.values.reduce(0, +)
	}

	func solvePart1(withInput input: Input) -> Int {
		Self.performCount(with: input.stones, numberOfCycles: 25)
	}

	func solvePart2(withInput input: Input) -> Int {
		Self.performCount(with: input.stones, numberOfCycles: 75)
	}

	func parseInput(rawString: String) -> Input {
		.init(stones: rawString.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ").map { Int($0)! })
	}
}
