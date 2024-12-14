import Foundation
import Tools

final class Day24Solver: DaySolver {
	let dayNumber: Int = 24

	struct Input {
		let lines: [[Direction]]
	}

	private enum Direction {
		case east
		case southEast
		case southWest
		case west
		case northWest
		case northEast
	}

	private func moveLine(_ line: [Direction]) -> Point2D {
		var point = Point2D()

		for direction in line {
			switch direction {
			case .west:
				point.x -= 1
			case .east:
				point.x += 1
			case .northWest:
				point.x -= (point.y & 1 == 0) ? 1 : 0
				point.y -= 1
			case .northEast:
				point.x += (point.y & 1 == 0) ? 0 : 1
				point.y -= 1
			case .southWest:
				point.x -= (point.y & 1 == 0) ? 1 : 0
				point.y += 1
			case .southEast:
				point.x += (point.y & 1 == 0) ? 0 : 1
				point.y += 1
			}
		}

		return point
	}

	func solvePart1(withInput input: Input) -> Int {
		var blackTiles: Set<Point2D> = Set()

		for line in input.lines {
			let point = moveLine(line)

			if blackTiles.contains(point) {
				blackTiles.remove(point)
			} else {
				blackTiles.insert(point)
			}
		}

		return blackTiles.count
	}

	private func pointsAroundTile(at point: Point2D) -> [Point2D] {
		let isEven = point.y & 1 == 0

		let points: [Point2D] = [
			point + Point2D(x: -1, y: 0),
			point + Point2D(x: 1, y: 0),
			point + Point2D(x: isEven ? -1 : 0, y: -1),
			point + Point2D(x: isEven ? 0 : 1, y: -1),
			point + Point2D(x: isEven ? -1 : 0, y: 1),
			point + Point2D(x: isEven ? 0 : 1, y: 1),
		]

		return points
	}

	func solvePart2(withInput input: Input) -> Int {
		var blackTiles: Set<Point2D> = Set()

		for line in input.lines {
			let point = moveLine(line)

			if blackTiles.contains(point) {
				blackTiles.remove(point)
			} else {
				blackTiles.insert(point)
			}
		}

		for _ in 0 ..< 100 {
			var newBlackTiles: Set<Point2D> = Set()

			for point in blackTiles {
				let points = pointsAroundTile(at: point)

				// for this black point we first check the count around to see if can stay black
				let count: Int = points.reduce(0) { result, point in
					result + (blackTiles.contains(point) ? 1 : 0)
				}

				if (1 ... 2).contains(count) {
					newBlackTiles.insert(point)
				}

				// we are also going to check all points and if they are white we need to check if they get flipped to black
				for point in points where blackTiles.contains(point) == false {
					let subPoints = pointsAroundTile(at: point)

					let subCount: Int = subPoints.reduce(0) { result, point in
						result + (blackTiles.contains(point) ? 1 : 0)
					}

					if subCount == 2 {
						newBlackTiles.insert(point)
					}
				}
			}

			blackTiles = newBlackTiles
		}

		return blackTiles.count
	}

	func parseInput(rawString: String) -> Input {
		var lines: [[Direction]] = []

		for line in rawString.allLines() {
			var scanIndex = 0

			var directions: [Direction] = []
			while scanIndex < line.count {
				let twoLetterScanIndex = min(scanIndex + 2, line.count)

				switch String(line[scanIndex ..< twoLetterScanIndex]) {
				case "se":
					directions.append(.southEast)
					scanIndex += 2

					continue
				case "sw":
					directions.append(.southWest)
					scanIndex += 2

					continue
				case "ne":
					directions.append(.northEast)
					scanIndex += 2

					continue
				case "nw":
					directions.append(.northWest)
					scanIndex += 2

					continue
				default:
					break
				}

				switch line[scanIndex ... scanIndex] {
				case "e":
					directions.append(.east)
				case "w":
					directions.append(.west)
				default: fatalError()
				}

				scanIndex += 1
			}

			lines.append(directions)
		}

		return .init(lines: lines)
	}
}
