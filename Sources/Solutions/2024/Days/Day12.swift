import Collections
import Foundation
import Tools

final class Day12Solver: DaySolver {
	let dayNumber: Int = 12

	struct Input {
		var map: [Point2D: Int]
	}

	private static func findArea(startingPoint: Point2D, in map: [Point2D: Int]) -> Set<Point2D> {
		let value = map[startingPoint]!

		var visited: Set<Point2D> = [startingPoint]
		var stack: Deque<Point2D> = [startingPoint]

		while let scanPosition = stack.popFirst() {
			for neighbor in scanPosition.neighbors() where !visited.contains(neighbor) {
				guard let neighborValue = map[neighbor], neighborValue == value else {
					continue
				}

				visited.insert(neighbor)

				stack.append(neighbor)
			}
		}

		return visited
	}

	func solvePart1(withInput input: Input) -> Int {
		let map = input.map

		let maxX = map.keys.map(\.x).max()!
		let maxY = map.keys.map(\.y).max()!

		var globalVisited: Set<Point2D> = []

		var result = 0

		for y in 0 ... maxY {
			for x in 0 ... maxX {
				let position = Point2D(x: x, y: y)

				guard !globalVisited.contains(position) else {
					continue
				}

				let visited = Self.findArea(startingPoint: position, in: map)
				let value = map[position]

				globalVisited.formUnion(visited)

				var perimeter = 0
				for point in visited {
					for neighbor in point.neighbors() {
						guard let neighborValue = map[neighbor] else {
							perimeter += 1

							continue
						}

						perimeter += neighborValue != value ? 1 : 0
					}
				}

				result += visited.count * perimeter
			}
		}

		return result
	}

	func solvePart2(withInput input: Input) -> Int {
		let map = input.map

		let maxX = map.keys.map(\.x).max()!
		let maxY = map.keys.map(\.y).max()!

		var globalVisited: Set<Point2D> = []

		var result = 0

		for y in 0 ... maxY {
			for x in 0 ... maxX {
				let position = Point2D(x: x, y: y)

				guard !globalVisited.contains(position) else {
					continue
				}

				let visited = Self.findArea(startingPoint: position, in: map)

				globalVisited.formUnion(visited)

				let scanMinY = visited.map(\.y).min()!
				let scanMaxY = visited.map(\.y).max()!
				let scanMinX = visited.map(\.x).min()!
				let scanMaxX = visited.map(\.x).max()!

				struct Intersection: Hashable {
					var startPoint: Point2D
					var endPoint: Point2D
					let isLeftMatching: Bool
				}

				var horizontalIntersections: [Int: [Intersection]] = [:]
				var verticalIntersections: [Int: [Intersection]] = [:]

				for y in scanMinY ... scanMaxY {
					for x in scanMinX - 1 ... scanMaxX {
						let scanPoint = Point2D(x: x, y: y)

						let northPoint = scanPoint.moved(to: .north)

						if visited.contains(scanPoint) != visited.contains(scanPoint.moved(to: .east)) {
							let isLeftMatching = visited.contains(scanPoint)

							if
								let overlappingIntersectionIndex = verticalIntersections[scanPoint.x, default: []].firstIndex(where: { existing in
									(existing.startPoint.y ... existing.endPoint.y).contains(northPoint.y) && existing.isLeftMatching == isLeftMatching
								})
							{
								verticalIntersections[scanPoint.x]![overlappingIntersectionIndex].endPoint = scanPoint
							} else {
								verticalIntersections[scanPoint.x, default: []].append(.init(startPoint: scanPoint, endPoint: scanPoint, isLeftMatching: isLeftMatching))
							}
						}
					}
				}

				for x in scanMinX ... scanMaxX {
					for y in scanMinY ... scanMaxY + 1 {
						let scanPoint = Point2D(x: x, y: y)

						let westPoint = scanPoint.moved(to: .west)

						if visited.contains(scanPoint) != visited.contains(scanPoint.moved(to: .north)) {
							let isLeftMatching = visited.contains(scanPoint)

							if
								let overlappingIntersectionIndex = horizontalIntersections[scanPoint.y, default: []].firstIndex(where: { existing in
									(existing.startPoint.x ... existing.endPoint.x).contains(westPoint.x) && existing.isLeftMatching == isLeftMatching
								})
							{
								horizontalIntersections[scanPoint.y]![overlappingIntersectionIndex].endPoint = scanPoint
							} else {
								horizontalIntersections[scanPoint.y, default: []].append(.init(startPoint: scanPoint, endPoint: scanPoint, isLeftMatching: isLeftMatching))
							}
						}
					}
				}

				let numberOfSections = verticalIntersections.values.map(\.count).reduce(0, +) + horizontalIntersections.values.map(\.count).reduce(0, +)

				result += visited.count * numberOfSections
			}
		}

		return result
	}

	func parseInput(rawString: String) -> Input {
		var map: [Point2D: Int] = [:]

		for (y, line) in rawString.allLines().enumerated() {
			for (x, character) in line.enumerated() {
				map[.init(x: x, y: y)] = Int(character.asciiValue! - AsciiCharacter.A)
			}
		}

		return .init(map: map)
	}
}
