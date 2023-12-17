import Collections
import Foundation
import Tools

final class Day17Solver: DaySolver {
	let dayNumber: Int = 17

	let expectedPart1Result = 791
	let expectedPart2Result = 900

	private var input: Input!

	private struct Input {
		let grid: [[Int]]
	}

	private struct UniqueState: Hashable {
		let point: Point2D
		let lastDirections: [Direction]
	}

	private struct QueueNode: Comparable {
		let point: Point2D
		let lastDirections: [Direction]
		let weight: Int

		static func < (lhs: QueueNode, rhs: QueueNode) -> Bool {
			lhs.weight < rhs.weight
		}
	}

	private func solve(withGrid grid: [[Int]], minRepeating: Int, maxRepeating: Int) -> Int {
		let size = Size(width: grid[0].count, height: grid.count)

		let a = Point2D(x: 0, y: 0)
		let b = Point2D(x: size.width - 1, y: size.height - 1)

		var priorityQueue = PriorityQueue<QueueNode>(isAscending: true)
		var weights: [Int: Int] = [UniqueState(point: .zero, lastDirections: []).hashValue: 0]

		priorityQueue.push(.init(point: a, lastDirections: [], weight: 0))

		while let solution = priorityQueue.pop() {
			if solution.point == b {
				return solution.weight
			}

			guard let currentWeight = weights[UniqueState(point: solution.point, lastDirections: solution.lastDirections).hashValue] else {
				preconditionFailure()
			}

			let newDirections: [Direction]

			if let lastDirection = solution.lastDirections.last {
				if minRepeating > 0, solution.lastDirections.suffix(minRepeating).count({ $0 == lastDirection }) < minRepeating {
					newDirections = [lastDirection]
				} else if Set(solution.lastDirections).count == 1 {
					newDirections = [
						lastDirection.left,
						lastDirection.right,
					]
				} else {
					newDirections = [
						lastDirection.left,
						lastDirection,
						lastDirection.right,
					]
				}
			} else {
				newDirections = [.east, .south] // node 0
			}

			for newDirection in newDirections {
				let newPoint = solution.point.moved(to: newDirection)

				guard (0 ..< size.width).contains(newPoint.x) && (0 ..< size.height).contains(newPoint.y) else {
					continue
				}

				let lastDirections = Array(solution.lastDirections.suffix(maxRepeating - 1) + [newDirection])

				if newPoint == b {
					if minRepeating > 0 {
						guard Set(lastDirections.suffix(minRepeating)).count == 1 else {
							continue
						}
					}
				}

				let stateHash = UniqueState(
					point: newPoint,
					lastDirections: lastDirections
				).hashValue

				let oldWeight = weights[stateHash]

				let combinedWeight = currentWeight + grid[newPoint.y][newPoint.x]

				if oldWeight == nil || combinedWeight < oldWeight! {
					weights[stateHash] = combinedWeight

					priorityQueue.push(
						QueueNode(
							point: newPoint,
							lastDirections: lastDirections,
							weight: combinedWeight
						)
					)
				}
			}
		}

		preconditionFailure()
	}

	func solvePart1() -> Int {
		solve(withGrid: input.grid, minRepeating: 0, maxRepeating: 3)
	}

	func solvePart2() -> Int {
		solve(withGrid: input.grid, minRepeating: 4, maxRepeating: 10)
	}

	func parseInput(rawString: String) {
		var grid: [[Int]] = []

		rawString.allLines().enumerated().forEach { _, line in
			grid.append(line.map { String($0) }.compactMap(Int.init))
		}

		input = .init(grid: grid)
	}
}
