import Collections
import Foundation
import Tools

/// Part 2 is solved by calculating the bounding box around the points with 1 empty row added in all dimensions. From the min point we perform a flood fill to fill all empty space
/// and immediately count the walls for each of these empty cells. BFS used to visit all nodes.
final class Day18Solver: DaySolver {
	let dayNumber: Int = 18

	struct Input {
		let points: Set<Point3D>
	}

	init() {}

	func solvePart1(withInput input: Input) -> Int {
		var sum = 0

		for point in input.points {
			for neighbor in point.neighbors() {
				sum += input.points.contains(neighbor) ? 0 : 1
			}
		}

		return sum
	}

	func solvePart2(withInput input: Input) -> Int {
		let points = input.points

		let minX = points.map(\.x).min()! - 1
		let maxX = points.map(\.x).max()! + 1

		let minY = points.map(\.y).min()! - 1
		let maxY = points.map(\.y).max()! + 1

		let minZ = points.map(\.z).min()! - 1
		let maxZ = points.map(\.z).max()! + 1

		let startPoint = Point3D(x: minX, y: minY, z: minZ)

		var visitedNodes: Set<Point3D> = [startPoint]

		var queue: Deque<Point3D> = [startPoint]

		var sum = 0

		// simple flood fill of outer area, immediately count encountered faces
		while let node = queue.popFirst() {
			for neighbor in node.neighbors() {
				if points.contains(neighbor) {
					sum += 1
				}

				guard
					visitedNodes.contains(neighbor) == false,
					(minX ... maxX).contains(neighbor.x),
					(minY ... maxY).contains(neighbor.y),
					(minZ ... maxZ).contains(neighbor.z),
					points.contains(neighbor) == false
				else {
					continue
				}

				queue.append(neighbor)

				visitedNodes.insert(neighbor)
			}
		}

		return sum
	}

	func parseInput(rawString: String) -> Input {
		.init(points: Set(rawString.allLines().map { line in
			Point3D(commaSeparatedString: line)
		}))
	}
}
