import Foundation
import Tools

final class Day17Solver: DaySolver {
	let dayNumber: Int = 17

	private var input: Input!

	private struct Input {
		let containers: [Int]
	}

	func fill(containers: [Int], amount: Int, numberOfContainers: Int, solutionsPerContainers: inout [Int: Int]) {
		for (index, container) in containers.enumerated() {
			if amount == container {
				solutionsPerContainers[numberOfContainers + 1, default: 0] += 1
			} else if amount > container {
				fill(
					containers: Array(containers[index + 1 ..< containers.count]),
					amount: amount - container,
					numberOfContainers: numberOfContainers + 1,
					solutionsPerContainers: &solutionsPerContainers
				)
			}
		}
	}

	func solvePart1() -> Int {
		var solutionsPerContainers: [Int: Int] = [:]

		fill(containers: input.containers, amount: 150, numberOfContainers: 0, solutionsPerContainers: &solutionsPerContainers)

		return solutionsPerContainers.values.reduce(0, +)
	}

	func solvePart2() -> Int {
		var solutionsPerContainers: [Int: Int] = [:]

		fill(containers: input.containers, amount: 150, numberOfContainers: 0, solutionsPerContainers: &solutionsPerContainers)

		return solutionsPerContainers.sorted(by: { $0.key < $1.key }).first!.value
	}

	func parseInput(rawString: String) {
		input = .init(containers: rawString.allLines().map { Int($0)! })
	}
}
