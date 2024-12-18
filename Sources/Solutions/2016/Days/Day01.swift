import Foundation
import Tools

final class Day01Solver: DaySolver {
	let dayNumber: Int = 1

	struct Input {
		let steps: [Step]
	}

	enum Step {
		case left(count: Int)
		case right(count: Int)
	}

	private var firstTwiceVisitedPoint: Point2D?

	func solvePart1(withInput input: Input) -> Int {
		var point = Point2D()
		var direction = Direction.north

		var visitedPoints: Set<Point2D> = []

		visitedPoints.insert(point)

		for step in input.steps {
			let moveCount: Int

			switch step {
			case .left(let count):
				direction = direction.left
				moveCount = count
			case .right(let count):
				direction = direction.right
				moveCount = count
			}

			for _ in 0 ..< moveCount {
				point = point.moved(to: direction, steps: 1)

				if firstTwiceVisitedPoint == nil {
					if visitedPoints.contains(point) {
						firstTwiceVisitedPoint = point
					}

					visitedPoints.insert(point)
				}
			}
		}

		return abs(point.x) + abs(point.y)
	}

	func solvePart2(withInput input: Input) -> Int {
		abs(firstTwiceVisitedPoint!.x) + abs(firstTwiceVisitedPoint!.y)
	}

	func parseInput(rawString: String) -> Input {
		let steps: [Step] = rawString
			.components(separatedBy: ",")
			.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
			.map { item in
				if item[0] == "L" {
					.left(count: Int(item[1 ..< item.count])!)
				} else if item[0] == "R" {
					.right(count: Int(item[1 ..< item.count])!)
				} else {
					fatalError()
				}
			}

		return .init(steps: steps)
	}
}
