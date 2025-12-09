import Collections
import Foundation
import Tools

final class Day09Solver: DaySolver {
	let dayNumber: Int = 9

	private var input: Input!

	struct Input {
		let redTiles: [Point2D]
	}

	func solvePart1(withInput input: Input) -> Int {
		let tiles = input.redTiles

		var largestArea = 0

		for i in 0 ..< tiles.count {
			for j in i + 1 ..< tiles.count {
				let a = tiles[i]
				let b = tiles[j]

				let delta = b - a

				let area = (abs(delta.x) + 1) * (abs(delta.y) + 1)

				largestArea = max(area, largestArea)
			}
		}

		return largestArea
	}

	func solvePart2(withInput input: Input) -> Int {
		let redTiles = input.redTiles

		struct Line {
			let a: Point2D
			let b: Point2D
		}

		var horizontalLines: [Line] = []
		var verticalLines: [Line] = []

		for redTileIndex in 0 ..< redTiles.count {
			let a = redTiles[redTileIndex]
			let b = redTiles[(redTileIndex + 1) % redTiles.count]

			let minY = min(a.y, b.y)
			let maxY = max(a.y, b.y)

			let minX = min(a.x, b.x)
			let maxX = max(a.x, b.x)

			let isHorizontal = maxY - minY == 0

			if isHorizontal {
				horizontalLines.append(Line(a: Point2D(x: minX, y: minY), b: Point2D(x: maxX, y: minY)))
			} else {
				verticalLines.append(Line(a: Point2D(x: minX, y: minY), b: Point2D(x: minX, y: maxY)))
			}
		}

		var largestArea = 0

		// go through all areas and intersect with the horizontal and vertical lines; any intersection and it is not a valid area
		for i in 0 ..< redTiles.count {
			jLoop: for j in i + 1 ..< redTiles.count {
				let a = redTiles[i]
				let b = redTiles[j]

				let tl = Point2D(x: min(a.x, b.x), y: min(a.y, b.y))
				let br = Point2D(x: max(a.x, b.x), y: max(a.y, b.y))

				let delta = br - tl

				let area = (delta.x + 1) * (delta.y + 1)

				// no need to check this area if it is not larger than already found largest area
				if area <= largestArea {
					continue
				}

				for line in horizontalLines {
					if line.a.y < tl.y || line.b.y > br.y || line.b.x < tl.x || line.a.x > br.x || line.a.y == tl.y || line.a.y == br.y {
						continue
					}

					continue jLoop
				}

				for line in verticalLines {
					if line.a.x < tl.x || line.b.x > br.x || line.b.y < tl.y || line.a.y > br.y || line.a.x == tl.x || line.a.x == br.x {
						continue
					}

					continue jLoop
				}

				largestArea = max(area, largestArea)
			}
		}

		return largestArea
	}

	func parseInput(rawString: String) -> Input {
		.init(redTiles: rawString.allLines().map { Point2D(commaSeparatedString: $0) })
	}
}
