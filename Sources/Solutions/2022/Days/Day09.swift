import Foundation
import Tools

final class Day09Solver: DaySolver {
	let dayNumber: Int = 9

	private var input: Input!

	private struct Input {
		let moves: [Move]
	}

	private struct Move {
		let direction: Direction
		let steps: Int
	}

	init() {}

	private func updateKnot(at: Point2D, withHead head: Point2D) -> Point2D {
		var newKnotPoint = at

		if abs(head.x - newKnotPoint.x) >= 2 || abs(head.y - newKnotPoint.y) >= 2 {
			if head.x != newKnotPoint.x {
				newKnotPoint.x += head.x > newKnotPoint.x ? 1 : -1
			}

			if head.y != newKnotPoint.y {
				newKnotPoint.y += head.y > newKnotPoint.y ? 1 : -1
			}
		}

		return newKnotPoint
	}

	func solvePart1() -> Int {
		var visitedPoints: Set<Point2D> = []

		var currentH = Point2D()
		var currentT = Point2D()

		for move in input.moves {
			for _ in 0 ..< move.steps {
				currentH = currentH.moved(to: move.direction)

				currentT = updateKnot(at: currentT, withHead: currentH)

				visitedPoints.insert(currentT)
			}
		}

		return visitedPoints.count
	}

	func solvePart2() -> Int {
		var visitedPoints: Set<Point2D> = []

		var currentH = Point2D()
		var allT: [Point2D] = Array(repeating: .zero, count: 9)

		for move in input.moves {
			for _ in 0 ..< move.steps {
				currentH = currentH.moved(to: move.direction)

				for pointIndex in 0 ..< allT.count {
					var currentT = allT[pointIndex]
					let relativeHead = allT[safe: pointIndex - 1] ?? currentH

					currentT = updateKnot(at: currentT, withHead: relativeHead)

					allT[pointIndex] = currentT
				}

				visitedPoints.insert(allT.last!)
			}
		}

		return visitedPoints.count
	}

	func parseInput(rawString: String) {
		input = .init(moves: rawString.allLines().map { line in
			let components = line.components(separatedBy: " ")

			switch components[0] {
			case "R":
				return .init(direction: .east, steps: Int(components[1])!)
			case "U":
				return .init(direction: .north, steps: Int(components[1])!)
			case "L":
				return .init(direction: .west, steps: Int(components[1])!)
			case "D":
				return .init(direction: .south, steps: Int(components[1])!)
			default:
				fatalError()
			}
		})
	}
}
