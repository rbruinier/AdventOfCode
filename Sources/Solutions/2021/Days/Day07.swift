import Foundation
import Tools

final class Day07Solver: DaySolver {
	let dayNumber: Int = 7

	struct Input {
		let positions: [Int]
	}

	func solvePart1(withInput input: Input) -> Int {
		let sortedPositions = input.positions.sorted()

		let median = sortedPositions[input.positions.count >> 1]

		let fuelUsage = input.positions.reduce(0) { result, position in
			result + abs(position - median)
		}

		return fuelUsage
	}

	func solvePart2(withInput input: Input) -> Int {
		// possible optimization: group by unique positions with count but this already currently performs well enough

		let minimumPosition = input.positions.min()!
		let maximumPosition = input.positions.max()!

		var bestFuelCost = Int.max

		for alignPosition in minimumPosition ... maximumPosition {
			let fuelUsage = input.positions.reduce(0) { result, position in
				// triangular number: https://en.wikipedia.org/wiki/Triangular_number
				let delta = abs(position - alignPosition)

				return result + ((delta * (delta + 1)) >> 1)
			}

			if fuelUsage < bestFuelCost {
				bestFuelCost = fuelUsage
			}
		}

		return bestFuelCost
	}

	func parseInput(rawString: String) -> Input {
		let rawNumbers = rawString
			.components(separatedBy: ",")
			.map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
			.compactMap { Int($0) }

		return .init(positions: rawNumbers)
	}
}
