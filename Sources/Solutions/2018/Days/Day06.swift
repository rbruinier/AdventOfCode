import Foundation
import Tools

final class Day06Solver: DaySolver {
	let dayNumber: Int = 6

	struct Input {
		let points: Set<Point2D>
		let safeDistanceThreshold: Int
	}

	func solvePart1(withInput input: Input) -> Int {
		let points = input.points

		let minX = points.map(\.x).min()! - 1
		let maxX = points.map(\.x).max()! + 1

		let minY = points.map(\.y).min()! - 1
		let maxY = points.map(\.y).max()! + 1

		var coordinatesByPoint: [Point2D: Set<Point2D>] = [:]

		for point in points {
			coordinatesByPoint[point] = Set([point])
		}

		var infinitePoints: Set<Point2D> = []
		var equalDistancePoints: Set<Point2D> = []

		for y in minY ... maxY {
			for x in minX ... maxX {
				let point = Point2D(x: x, y: y)

				guard points.contains(point) == false else {
					continue
				}

				let sortedPoints = points
					.sorted(by: { $0.manhattanDistance(from: point) < $1.manhattanDistance(from: point) })
					.prefix(2)

				let firstPoint = sortedPoints[0]
				let secondPoint = sortedPoints[1]

				guard infinitePoints.contains(firstPoint) == false else {
					continue
				}

				if secondPoint.manhattanDistance(from: point) == firstPoint.manhattanDistance(from: point) {
					equalDistancePoints.insert(point)
				} else {
					if y == minY || y == maxY || x == minX || x == maxX {
						infinitePoints.insert(firstPoint)
					} else {
						coordinatesByPoint[firstPoint]!.insert(point)
					}
				}
			}
		}

		return coordinatesByPoint
			.sorted(by: { $0.value.count > $1.value.count })
			.first!
			.value
			.count
	}

	func solvePart2(withInput input: Input) -> Int {
		let points = input.points

		let minX = points.map(\.x).min()! - 1
		let maxX = points.map(\.x).max()! + 1

		let minY = points.map(\.y).min()! - 1
		let maxY = points.map(\.y).max()! + 1

		var coordinatesByPoint: [Point2D: Set<Point2D>] = [:]

		for point in points {
			coordinatesByPoint[point] = Set([point])
		}

		var nrOfSafeCoordinates = 0
		for y in minY ... maxY {
			for x in minX ... maxX {
				let coordinate = Point2D(x: x, y: y)

				var combinedDistance = 0
				for point in points {
					combinedDistance += point.manhattanDistance(from: coordinate)

					if combinedDistance >= input.safeDistanceThreshold {
						break
					}
				}

				if combinedDistance < input.safeDistanceThreshold {
					nrOfSafeCoordinates += 1
				}
			}
		}

		return nrOfSafeCoordinates
	}

	func parseInput(rawString: String) -> Input {
		return .init(
			points: Set(rawString.allLines().map { line in
				Point2D(commaSeparatedString: line.replacingOccurrences(of: " ", with: ""))
			}),
			safeDistanceThreshold: 10000
		)
	}
}
