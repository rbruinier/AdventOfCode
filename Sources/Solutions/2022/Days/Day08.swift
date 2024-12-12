import Foundation
import Tools

final class Day08Solver: DaySolver {
	let dayNumber: Int = 8

	private var input: Input!

	private struct Input {
		let heights: [Point2D: Int]
	}

	init() {}

	private func isVisibleFromAnEdge(at point: Point2D, heights: [Point2D: Int]) -> Bool {
		let treeHeight = heights[point]!

		directionLoop: for direction in Direction.allStraight {
			var currentPoint = point.moved(to: direction)

			while let otherHeight = heights[currentPoint] {
				if otherHeight >= treeHeight {
					continue directionLoop
				}

				currentPoint = currentPoint.moved(to: direction)
			}

			return true
		}

		return false
	}

	private func scenicScore(at point: Point2D, heights: [Point2D: Int]) -> Int {
		let treeHeight = heights[point]!

		var scenicScore = 1

		for direction in Direction.allStraight {
			var currentPoint = point.moved(to: direction)

			var visibleDistance = 0

			while let otherHeight = heights[currentPoint] {
				visibleDistance += 1

				if otherHeight >= treeHeight {
					break
				}

				currentPoint = currentPoint.moved(to: direction)
			}

			scenicScore *= visibleDistance
		}

		return scenicScore
	}

	func solvePart1() -> Int {
		var isVisibleFromAnEdgeCounter = 0

		for point in input.heights.keys {
			isVisibleFromAnEdgeCounter += isVisibleFromAnEdge(at: point, heights: input.heights) ? 1 : 0
		}

		return isVisibleFromAnEdgeCounter
	}

	func solvePart2() -> Int {
		var maxScenicScore = 0

		for point in input.heights.keys {
			maxScenicScore = max(maxScenicScore, scenicScore(at: point, heights: input.heights))
		}

		return maxScenicScore
	}

	func parseInput(rawString: String) {
		var heights: [Point2D: Int] = [:]

		for (y, line) in rawString.allLines().enumerated() {
			for (x, height) in line.enumerated() {
				heights[.init(x: x, y: y)] = Int(String(height))!
			}
		}

		input = .init(heights: heights)
	}
}
