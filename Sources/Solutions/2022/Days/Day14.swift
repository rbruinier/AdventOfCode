import Foundation
import Tools

final class Day14Solver: DaySolver {
	let dayNumber: Int = 14

	struct Input {
		let paths: [Path]
	}

	struct Path {
		let points: [Point2D]
	}

	init() {}

	private func blockedPoints(with paths: [Path]) -> Set<Point2D> {
		var blockedPoints: Set<Point2D> = []

		for path in paths {
			for index in 0 ..< path.points.count - 1 {
				var currentPoint = path.points[index]
				let nextPoint = path.points[index + 1]

				blockedPoints.insert(currentPoint)

				while currentPoint != nextPoint {
					currentPoint.x += (nextPoint.x - currentPoint.x).sign
					currentPoint.y += (nextPoint.y - currentPoint.y).sign

					blockedPoints.insert(currentPoint)
				}
			}
		}

		return blockedPoints
	}

	func solvePart1(withInput input: Input) -> Int {
		let sandStartPoint = Point2D(x: 500, y: 0)

		var blockedPoints = blockedPoints(with: input.paths)

		let bottomY = blockedPoints.map(\.y).max()!

		var grainsOfSand = 0
		sandLoop: while true {
			var currentPoint = sandStartPoint

			moveLoop: while true {
				let down = currentPoint.moved(to: .south)
				let downLeft = down.moved(to: .west)
				let downRight = down.moved(to: .east)

				if currentPoint.y > bottomY {
					break sandLoop
				}

				if blockedPoints.contains(down) == false {
					currentPoint = down

					continue moveLoop
				}

				if blockedPoints.contains(downLeft) == false {
					currentPoint = downLeft

					continue moveLoop
				}

				if blockedPoints.contains(downRight) == false {
					currentPoint = downRight

					continue moveLoop
				}

				blockedPoints.insert(currentPoint)

				grainsOfSand += 1

				break moveLoop
			}
		}

		return grainsOfSand
	}

	func solvePart2(withInput input: Input) -> Int {
		let sandStartPoint = Point2D(x: 500, y: 0)

		var blockedPoints = blockedPoints(with: input.paths)

		let bottomY = blockedPoints.map(\.y).max()!
		let virtualBottomY = bottomY + 2

		var grainsOfSand = 0
		sandLoop: while true {
			var currentPoint = sandStartPoint

			moveLoop: while true {
				let down = currentPoint.moved(to: .south)
				let downLeft = down.moved(to: .west)
				let downRight = down.moved(to: .east)

				if down.y == virtualBottomY {
					blockedPoints.insert(currentPoint)

					grainsOfSand += 1

					break moveLoop
				}

				if blockedPoints.contains(down) == false {
					currentPoint = down

					continue moveLoop
				}

				if blockedPoints.contains(downLeft) == false, currentPoint.y < virtualBottomY {
					currentPoint = downLeft

					continue moveLoop
				}

				if blockedPoints.contains(downRight) == false {
					currentPoint = downRight

					continue moveLoop
				}

				blockedPoints.insert(currentPoint)

				grainsOfSand += 1

				if currentPoint == sandStartPoint {
					break sandLoop
				}

				break moveLoop
			}
		}

		return grainsOfSand
	}

	func parseInput(rawString: String) -> Input {
		return .init(paths: rawString.allLines().map { line in
			Path(points: line.components(separatedBy: " -> ").map { components in
				Point2D(commaSeparatedString: components)
			})
		})
	}
}
