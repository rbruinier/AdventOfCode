import Foundation
import Tools

final class Day01Solver: DaySolver {
	let dayNumber: Int = 1

	private var input: Input!

	private struct Input {
		let listA: [Int]
		let listB: [Int]
	}

	func solvePart1() -> Int {
		let aValues: [Int] = input.listA.sorted()
		let bValues: [Int] = input.listB.sorted()

		var totalDistance = 0
		for (a, b) in zip(aValues, bValues) {
			totalDistance += abs(a - b)
		}

		return totalDistance
	}

	func solvePart2() -> Int {
		let aValues: [Int] = input.listA
		let bValues: [Int] = input.listB

		var totalScore = 0
		for a in aValues {
			let occurencesInB = bValues.count { $0 == a }

			totalScore += a * occurencesInB
		}

		return totalScore
	}

	func parseInput(rawString: String) {
		var listA: [Int] = []
		var listB: [Int] = []

		for line in rawString.allLines() {
			let components = line.components(separatedBy: .whitespaces)

			var listIndex = 0
			for component in components where !component.isEmpty {
				assert(listIndex <= 1)

				if listIndex == 0 {
					listA.append(Int(component)!)
				} else {
					listB.append(Int(component)!)
				}

				listIndex += 1
			}
		}

		input = .init(listA: listA, listB: listB)
	}
}
