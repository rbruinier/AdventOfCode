import Collections
import Foundation
import Tools

final class Day18Solver: DaySolver {
	let dayNumber: Int = 18

	struct Input {
		let bytes: [Point2D]
	}

	private func findShortestPath(with walls: Set<Point2D>) -> (path: Set<Point2D>, cost: Int)? {
		struct Node: Comparable {
			var position: Point2D
			var cost: Int
			var history: Set<Point2D>

			static func < (lhs: Node, rhs: Node) -> Bool {
				lhs.cost < rhs.cost
			}
		}

		let start = Point2D(x: 0, y: 0)
		let end = Point2D(x: 70, y: 70)

		var priorityQueue = PriorityQueue<Node>()

		priorityQueue.insert(Node(position: start, cost: 0, history: [start]))

		var costs: [Point2D: Int] = [
			start: 0,
		]

		while let node = priorityQueue.popMin() {
			if node.position == end {
				return (path: node.history, cost: node.cost)
			}

			let newCost = node.cost + 1

			for neighbor in node.position.neighbors() {
				guard
					(0 ... end.x).contains(neighbor.x),
					(0 ... end.y).contains(neighbor.y),
					!walls.contains(neighbor)
				else {
					continue
				}

				let oldCost = costs[neighbor]

				if oldCost == nil || newCost < oldCost! {
					costs[neighbor] = newCost

					priorityQueue.insert(.init(position: neighbor, cost: newCost, history: node.history.union([neighbor])))
				}
			}
		}

		return nil
	}

	func solvePart1(withInput input: Input) -> Int {
		findShortestPath(with: Set(input.bytes[0 ..< 1024]))!.cost
	}

	func solvePart2(withInput input: Input) -> String {
		var currentPath: Set<Point2D> = []

		maxBytesLoop: for maxBytes in 1024 ..< input.bytes.count {
			let currentMaxByte = input.bytes[maxBytes]

			// in case the new byte is not in the way of the current path the shortest route will stay exactly the same, so skip
			if currentPath.isNotEmpty, !currentPath.contains(currentMaxByte) {
				continue
			}

			let walls: Set<Point2D> = Set(input.bytes[0 ... maxBytes])

			if let shortestPath = findShortestPath(with: walls) {
				currentPath = shortestPath.path
			} else {
				return "\(currentMaxByte.x),\(currentMaxByte.y)"
			}
		}

		preconditionFailure()
	}

	func parseInput(rawString: String) -> Input {
		.init(bytes: rawString.allLines().map { line in
			let values = line.parseCommaSeparatedInts()

			return Point2D(x: values[0], y: values[1])
		})
	}
}
