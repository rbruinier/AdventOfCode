import Foundation
import Tools

final class Day06Solver: DaySolver {
	let dayNumber: Int = 6

	struct Input {
		let initialTimers: [Int]
	}

	private struct AgeGroup {
		var nrOfFish: Int = 0
	}

	private func runFor(iterations: Int, initialTimers: [Int]) -> Int {
		var ageGroups: [AgeGroup] = Array(repeating: .init(), count: 9)

		for input in initialTimers {
			ageGroups[input].nrOfFish += 1
		}

		for _ in 0 ..< iterations {
			var newAgeGroups: [AgeGroup] = Array(repeating: .init(), count: 9)

			for age in stride(from: 8, through: 0, by: -1) {
				if age >= 1 {
					newAgeGroups[age - 1].nrOfFish = ageGroups[age].nrOfFish
				} else {
					newAgeGroups[8].nrOfFish = ageGroups[0].nrOfFish
					newAgeGroups[6].nrOfFish += ageGroups[0].nrOfFish
				}
			}

			ageGroups = newAgeGroups
		}

		return ageGroups.reduce(0) { result, group in
			result + group.nrOfFish
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		runFor(iterations: 80, initialTimers: input.initialTimers)
	}

	func solvePart2(withInput input: Input) -> Int {
		runFor(iterations: 256, initialTimers: input.initialTimers)
	}

	func parseInput(rawString: String) -> Input {
		let rawNumbers = rawString
			.components(separatedBy: ",")
			.map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
			.compactMap { Int($0) }

		return .init(initialTimers: rawNumbers)
	}
}
