import Foundation
import Tools

final class Day01Solver: DaySolver {
	let dayNumber: Int = 1

	struct Input {
		let masses: [Int]
	}

	private func calculateFuel(for mass: Int) -> Int {
		(mass / 3) - 2
	}

	func solvePart1(withInput input: Input) -> Int {
		input.masses.reduce(0) { result, mass in
			result + calculateFuel(for: mass)
		}
	}

	func solvePart2(withInput input: Input) -> Int {
		input.masses.reduce(0) { result, mass in
			var sum = 0
			var remainingMass = mass

			while true {
				let result = calculateFuel(for: remainingMass)

				if result <= 0 {
					break
				}

				sum += result
				remainingMass = result
			}

			return result + sum
		}
	}

	func parseInput(rawString: String) -> Input {
		return .init(masses: rawString.allLines().map { Int($0)! })
	}
}
