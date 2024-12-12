import Foundation
import Tools

final class Day12Solver: DaySolver {
	let dayNumber: Int = 12

	private var input: Input!

	private struct Input {
		let pipes: [Int: [Int]]
	}

	private func visitAllFromStartID(_ startID: Int, allPipes: [Int: [Int]], visitedPipes: inout Set<Int>) {
		guard visitedPipes.contains(startID) == false else {
			return
		}

		visitedPipes.insert(startID)

		for toID in allPipes[startID]! {
			visitAllFromStartID(toID, allPipes: allPipes, visitedPipes: &visitedPipes)
		}
	}

	func solvePart1() -> Int {
		var visitedPipes: Set<Int> = []

		visitAllFromStartID(0, allPipes: input.pipes, visitedPipes: &visitedPipes)

		return visitedPipes.count
	}

	func solvePart2() -> Int {
		var combinedVisitedPipes: Set<Int> = []

		var groupCount = 0
		for startPipeID in input.pipes.keys where combinedVisitedPipes.contains(startPipeID) == false {
			var visitedPipes: Set<Int> = []

			visitAllFromStartID(startPipeID, allPipes: input.pipes, visitedPipes: &visitedPipes)

			combinedVisitedPipes = combinedVisitedPipes.union(visitedPipes)

			groupCount += 1
		}

		return groupCount
	}

	func parseInput(rawString: String) {
		input = .init(pipes: rawString.allLines().reduce(into: [Int: [Int]]()) { result, line in
			let components = line.components(separatedBy: " <-> ")

			let start = Int(components[0])!
			let to = components[1].components(separatedBy: ", ").map { Int($0)! }

			result[start] = to
		})
	}
}
