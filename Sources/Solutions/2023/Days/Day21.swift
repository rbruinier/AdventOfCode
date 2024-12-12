import Collections
import Foundation
import Tools

final class Day21Solver: DaySolver {
	let dayNumber: Int = 21

	private var input: Input!

	private struct Input {
		let rocks: Set<Point2D>
		let start: Point2D
		let range: Size
	}

	private func numberOfReachableSpots(from start: Point2D, rocks: Set<Point2D>, range: Size, steps: Int) -> Int {
		var reachedPoints: Set<Point2D> = [start]

		for _ in 0 ..< steps {
			var newReachedPoints: Set<Point2D> = .init(minimumCapacity: reachedPoints.count * 2)

			for newReachedPoint in reachedPoints {
				for neighbor in newReachedPoint.neighbors() where !newReachedPoints.contains(neighbor) {
					guard
						(0 ..< range.width).contains(neighbor.x),
						(0 ..< range.height).contains(neighbor.y),
						!rocks.contains(neighbor)
					else {
						continue
					}

					newReachedPoints.insert(neighbor)
				}
			}

			reachedPoints = newReachedPoints
		}

		return reachedPoints.count
	}

	func solvePart1() -> Int {
		numberOfReachableSpots(from: input.start, rocks: input.rocks, range: input.range, steps: 64)
	}

	/*
	 Solution with assumptions, so only works with the given input:
	  * grid is square
	  * grid is odd length (131) (0 ... 130 x 0 ... 130)
	  * starting point is right in the center 64, 64
	  * from the starting point to the edges in straight lines there are no obstructions (see the input)

	 Constants:
	  * number of steps = 26501365 (from the puzzle requirement)
	  * tile size = 131
	  * number of reachable tiles (excluding starting tile in straight directions = (26501365 - 65) / 131 = 202300)

	 What we can reach depends on goal steps:
	  * if it is an even number we can reach for example starting point in starting tile
	  * if uneven we can never reach starting point in starting tile
	  * but as the tile size is UNEVEN it is the opposite for the 4 neighboring tiles. basically it is a checkerboard pattern of even/odd tiles
	  * in this case the number of steps is uneven so in the starting tile we cannot reach the starting point, but we can in the 4 neighboring tiles

	 Observations:
	  * as we know the 4 outer edges we could draw a diamond from those points and see what tiles are in and on the edge of this diamond
	  * whatever is on the border can be semi reached, these are the only tiles where we would need to do extra calculations
	  * if we tilt the diamond 45 degrees left or right we actually end up with a square, this is important:
	 - this allows us to relatively simply calculate the area of the bulk of the tiles not on the edge
	  * the edges have a repeating pattern of two types of cut off: a small one and a big one

	 See also the diagram in the "Other" folder: Day21.Part2.
	 */
	func solvePart2() -> Int {
		// constants:
		let numberOfSteps = 26501365
		let tileSize = 131
		let maxNumberOfReachableTiles = numberOfSteps / tileSize
		let remainderSteps = numberOfSteps % tileSize

		let numberOfWholeTilesInOneDirection = maxNumberOfReachableTiles - 1 // - -1 for the edge

		// number of points reachable in odd tiles and even tiles
		let numberOfOddReachablePoints = numberOfReachableSpots(from: input.start, rocks: input.rocks, range: input.range, steps: tileSize * 2 + 1)
		let numberOfEvenReachablePoints = numberOfReachableSpots(from: input.start, rocks: input.rocks, range: input.range, steps: tileSize * 2)

		// get the total number of even and odd tiles (making use of the fact that this area is a square)
		let numberOfOddTiles = ((numberOfWholeTilesInOneDirection / 2) * 2 + 1).squared // + 1 for the center tile
		let numberOfEvenTiles = ((numberOfWholeTilesInOneDirection + 1) / 2 * 2).squared

		// the four edge points of the diamond shape made by the horizontal and vertical limits
		let northPoints = numberOfReachableSpots(from: .init(x: input.start.x, y: tileSize - 1), rocks: input.rocks, range: input.range, steps: tileSize - 1)
		let southPoints = numberOfReachableSpots(from: .init(x: input.start.x, y: 0), rocks: input.rocks, range: input.range, steps: tileSize - 1)
		let westPoints = numberOfReachableSpots(from: .init(x: tileSize - 1, y: input.start.y), rocks: input.rocks, range: input.range, steps: tileSize - 1)
		let eastPoints = numberOfReachableSpots(from: .init(x: 0, y: input.start.y), rocks: input.rocks, range: input.range, steps: tileSize - 1)

		// there are two types of subdivisions of edge nodes, small and big
		let smallSteps = remainderSteps - 1

		let smallEnterTopRight = numberOfReachableSpots(from: .init(x: tileSize - 1, y: 0), rocks: input.rocks, range: input.range, steps: smallSteps)
		let smallEnterBottomRight = numberOfReachableSpots(from: .init(x: tileSize - 1, y: tileSize - 1), rocks: input.rocks, range: input.range, steps: smallSteps)
		let smallEnterTopLeft = numberOfReachableSpots(from: .init(x: 0, y: 0), rocks: input.rocks, range: input.range, steps: smallSteps)
		let smallEnterBottomLeft = numberOfReachableSpots(from: .init(x: 0, y: tileSize - 1), rocks: input.rocks, range: input.range, steps: smallSteps)

		let bigSteps = tileSize + remainderSteps - 1

		let bigEnterTopRight = numberOfReachableSpots(from: .init(x: tileSize - 1, y: 0), rocks: input.rocks, range: input.range, steps: bigSteps)
		let bigEnterBottomRight = numberOfReachableSpots(from: .init(x: tileSize - 1, y: tileSize - 1), rocks: input.rocks, range: input.range, steps: bigSteps)
		let bigEnterTopLeft = numberOfReachableSpots(from: .init(x: 0, y: 0), rocks: input.rocks, range: input.range, steps: bigSteps)
		let bigEnterBottomLeft = numberOfReachableSpots(from: .init(x: 0, y: tileSize - 1), rocks: input.rocks, range: input.range, steps: bigSteps)

		let parts: [Int] = [
			numberOfOddTiles * numberOfOddReachablePoints,
			numberOfEvenTiles * numberOfEvenReachablePoints,
			northPoints,
			southPoints,
			westPoints,
			eastPoints,
			(numberOfWholeTilesInOneDirection + 1) * (smallEnterTopRight + smallEnterBottomRight + smallEnterTopLeft + smallEnterBottomLeft) +
				numberOfWholeTilesInOneDirection * (bigEnterTopRight + bigEnterBottomRight + bigEnterTopLeft + bigEnterBottomLeft),
		]

		return parts.reduce(0, +)
	}

	func parseInput(rawString: String) {
		var range: Size = .zero
		var start: Point2D = .zero
		var rocks: Set<Point2D> = []

		_ = rawString.parseGrid { (character: String, point: Point2D) -> Int? in
			range = .init(width: max(range.width, point.x + 1), height: max(range.height, point.y + 1))

			if character == "#" {
				rocks.insert(point)
			} else if character == "S" {
				start = point
			}

			return nil
		}

		input = .init(rocks: rocks, start: start, range: range)
	}
}
