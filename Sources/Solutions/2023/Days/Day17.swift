import Collections
import Foundation
import Tools

final class Day17Solver: DaySolver {
	let dayNumber: Int = 17

	private var input: Input!

	private struct Input {
		let grid: [[Int]]
	}

	private struct UniqueState: Hashable {
		let point: Point2D
		let direction: Direction
		let directionCount: Int
	}

	private struct QueueNode: Comparable {
		let point: Point2D
		let direction: Direction
		let directionCount: Int
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

		var weights: [Int: Int] = [
			UniqueState(point: .zero, direction: .east, directionCount: 0).hashValue: 0,
		]

		priorityQueue.push(.init(point: a, direction: .east, directionCount: 0, weight: 0))

		while let solution = priorityQueue.pop() {
			if solution.point == b {
				return solution.weight
			}

			guard let currentWeight = weights[UniqueState(point: solution.point, direction: solution.direction, directionCount: solution.directionCount).hashValue] else {
				preconditionFailure()
			}

			let newDirections: [Direction]

			let lastDirection = solution.direction

			if minRepeating > 0, solution.directionCount < minRepeating {
				newDirections = [lastDirection]
			} else if solution.directionCount >= maxRepeating {
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

			for newDirection in newDirections {
				let newPoint = solution.point.moved(to: newDirection)

				guard (0 ..< size.width).contains(newPoint.x) && (0 ..< size.height).contains(newPoint.y) else {
					continue
				}

				let directionCount = (newDirection == solution.direction) ? (solution.directionCount + 1) : 1

				if newPoint == b, minRepeating > 0, directionCount < minRepeating {
					continue
				}

				let stateHash = UniqueState(
					point: newPoint,
					direction: newDirection,
					directionCount: directionCount
				).hashValue

				let oldWeight = weights[stateHash]

				let combinedWeight = currentWeight + grid[newPoint.y][newPoint.x]

				if oldWeight == nil || combinedWeight < oldWeight! {
					weights[stateHash] = combinedWeight

					priorityQueue.push(
						QueueNode(
							point: newPoint,
							direction: newDirection,
							directionCount: directionCount,
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
