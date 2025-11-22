import Collections
import Foundation
import Tools

final class Day13Solver: DaySolver {
	let dayNumber: Int = 13

	struct Input {
		let favoriteNumber = 1362
		let destination = Point2D(x: 31, y: 39)
	}

	private enum Tile {
		case empty
		case wall
	}

	private struct Step {
		let point: Point2D
		let nrOfSteps: Int
	}

	private func isWall(at point: Point2D, favoriteNumber: Int) -> Bool {
		let z = (point.x * point.x + 3 * point.x + 2 * point.x * point.y + point.y + point.y * point.y) + favoriteNumber

		var count = 0
		for bitIndex in 0 ..< 32 {
			count += (z >> bitIndex) & 1
		}

		return count.isOdd
	}

	func solvePart1(withInput input: Input) -> Int {
		var visitedPoints: Set<Point2D> = []

		var queue: Deque<Step> = [.init(point: Point2D(x: 1, y: 1), nrOfSteps: 0)]

		var shortestSteps = Int.max

		while let step = queue.popFirst() {
			if step.point == input.destination {
				shortestSteps = min(shortestSteps, step.nrOfSteps)
			}

			for newPoint in step.point.neighbors() where newPoint.x >= 0 && newPoint.y >= 0 && visitedPoints.contains(newPoint) == false {
				visitedPoints.insert(newPoint)

				guard isWall(at: newPoint, favoriteNumber: input.favoriteNumber) == false else {
					continue
				}

				queue.append(.init(point: newPoint, nrOfSteps: step.nrOfSteps + 1))
			}
		}

		return shortestSteps
	}

	func solvePart2(withInput input: Input) -> Int {
		var reachablePoints: Set<Point2D> = []

		for y in (0 ... 51).reversed() {
			for x in (0 ... 51).reversed() {
				let destination = Point2D(x: x, y: y)

				if reachablePoints.contains(destination) {
					continue
				}

				guard isWall(at: destination, favoriteNumber: input.favoriteNumber) == false else {
					continue
				}

				var visitedPoints: Set<Point2D> = []

				var queue: Deque<Step> = [.init(point: Point2D(x: 1, y: 1), nrOfSteps: 0)]

				while let step = queue.popFirst() {
					if step.point == destination {
						break
					}

					guard step.nrOfSteps <= 49 else {
						continue
					}

					for newPoint in step.point.neighbors() {
						guard
							newPoint.x >= 0,
							newPoint.y >= 0,
							newPoint.x <= 51,
							newPoint.y <= 51,
							visitedPoints.contains(newPoint) == false
						else {
							continue
						}

						visitedPoints.insert(newPoint)

						guard isWall(at: newPoint, favoriteNumber: input.favoriteNumber) == false else {
							continue
						}

						reachablePoints.insert(newPoint)

						queue.append(.init(point: newPoint, nrOfSteps: step.nrOfSteps + 1))
					}
				}
			}
		}

		return reachablePoints.count
	}

	func parseInput(rawString: String) -> Input {
		.init()
	}
}
