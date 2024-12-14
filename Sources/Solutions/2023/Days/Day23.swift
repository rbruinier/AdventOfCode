import Collections
import Foundation
import Tools

/// For part 2 we first build a graph with weights so that we can move through the grid without doing individual steps in the "hallways".
final class Day23Solver: DaySolver {
	let dayNumber: Int = 23

	typealias Grid = [Point2D: Tile]

	struct Input {
		let grid: Grid
		let size: Size
	}

	enum Tile: Equatable {
		case empty
		case wall
		case slope(direction: Direction)
	}

	private struct GraphData {
		let graph: WeightedGraph
		let startIndex: Int
		let endIndex: Int
	}

	private func buildGraph(for grid: Grid, size: Size, start: Point2D, goal: Point2D) -> GraphData {
		struct Node {
			let position: Point2D
			let graphNodeIndex: Int
			let parentJunctionPosition: Point2D?
		}

		var queue: Deque<Node> = [.init(position: start, graphNodeIndex: 0, parentJunctionPosition: nil)]

		var edges: [WeightedGraph.Edge] = []
		var graphNodes: [Point2D] = [start]

		let startIndex = 0
		var goalIndex: Int?

		while let node = queue.popFirst() {
			var currentPosition = node.position

			var path: Set<Point2D> = [currentPosition]

			while true {
				var possibleDestinations: Set<Point2D> = []

				for neighbor in currentPosition.neighbors() {
					guard
						(0 ..< size.width).contains(neighbor.x),
						(0 ..< size.height).contains(neighbor.y),
						grid[neighbor] != .wall,
						!path.contains(neighbor),
						(node.parentJunctionPosition == nil || node.parentJunctionPosition! != neighbor)
					else {
						continue
					}

					possibleDestinations.insert(neighbor)
				}

				if possibleDestinations.count == 1 {
					currentPosition = possibleDestinations.first!

					if currentPosition == goal {
						goalIndex = graphNodes.count

						edges.append(.init(a: node.graphNodeIndex, b: graphNodes.count, weight: path.count))
						graphNodes.append(currentPosition)

						break
					}

					path.insert(currentPosition)
				} else {
					if let existingNode = graphNodes.firstIndex(of: currentPosition) {
						edges.append(.init(a: node.graphNodeIndex, b: existingNode, weight: path.count))
					} else {
						edges.append(.init(a: node.graphNodeIndex, b: graphNodes.count, weight: path.count))
						graphNodes.append(currentPosition)

						for possibleDestination in possibleDestinations {
							queue.insert(.init(
								position: possibleDestination,
								graphNodeIndex: graphNodes.count - 1,
								parentJunctionPosition: currentPosition
							), at: 0)
						}
					}

					break
				}
			}
		}

		return .init(
			graph: WeightedGraph(elementsCount: graphNodes.count, edges: edges),
			startIndex: startIndex,
			endIndex: goalIndex!
		)
	}

	private func solvePart1(startAt start: Point2D, goal: Point2D, grid: Grid, size: Size) -> Int {
		struct Node {
			let position: Point2D
			let steps: Int
			let visitedPoints: [Point2D]
		}

		var visitedPoints: [Point2D: Int] = [start: 0]
		var queue: Deque<Node> = [Node(position: start, steps: 0, visitedPoints: [start])]

		var maxDistance = Int.min

		while let node = queue.popFirst() {
			if node.position == goal {
				maxDistance = max(maxDistance, node.steps)

				continue
			}

			for neighbor in node.position.neighbors() {
				guard
					(0 ..< size.width).contains(neighbor.x),
					(0 ..< size.height).contains(neighbor.y),
					!node.visitedPoints.contains(neighbor)
				else {
					continue
				}

				let nodeType = grid[neighbor]!

				switch nodeType {
				case .wall:
					continue
				case .empty:
					break
				case .slope(let slopeDirection):
					let stepDirection: Direction

					if node.position.x == neighbor.x {
						stepDirection = neighbor.y > node.position.y ? .south : .north
					} else {
						stepDirection = neighbor.x > node.position.x ? .east : .west
					}

					if stepDirection != slopeDirection {
						continue
					}
				}

				let steps = node.steps + 1

				// early out if we have a path with more steps
				if steps < visitedPoints[neighbor, default: 0] {
					continue
				}

				visitedPoints[neighbor] = node.steps

				queue.insert(.init(position: neighbor, steps: steps, visitedPoints: node.visitedPoints + [neighbor]), at: 0)
			}
		}

		return maxDistance
	}

	private func longestPathInGraph(_ graph: WeightedGraph, startIndex: Int, goalIndex: Int, steps: Int, visitedNodes: inout Int) -> Int {
		if startIndex == goalIndex {
			return steps
		}

		var highestWeight = Int.min

		let edges = graph.edgesByElement[startIndex]!

		visitedNodes |= (1 << startIndex)

		for edge in edges where (visitedNodes & (1 << edge.b)) == 0 {
			highestWeight = max(highestWeight, longestPathInGraph(graph, startIndex: edge.b, goalIndex: goalIndex, steps: steps + edge.weight, visitedNodes: &visitedNodes))
		}

		visitedNodes &= ~(1 << startIndex)

		return highestWeight
	}

	func solvePart1(withInput input: Input) -> Int {
		let start = Point2D(x: 1, y: 0)
		let goal = Point2D(x: input.size.width - 2, y: input.size.height - 1)

		return solvePart1(startAt: start, goal: goal, grid: input.grid, size: input.size)
	}

	func solvePart2(withInput input: Input) -> Int {
		let start = Point2D(x: 1, y: 0)
		let goal = Point2D(x: input.size.width - 2, y: input.size.height - 1)

		let graphData = buildGraph(for: input.grid, size: input.size, start: start, goal: goal)

		// we store visited nodes in an Int using bit flags as there are only 36 junctions/nodes
		var visitedNodes = 0

		return longestPathInGraph(graphData.graph, startIndex: graphData.startIndex, goalIndex: graphData.endIndex, steps: 0, visitedNodes: &visitedNodes)
	}

	func parseInput(rawString: String) -> Input {
		let grid: [Point2D: Tile] = rawString.parseGrid { character, _ in
			switch character {
			case ".": .empty
			case "#": .wall
			case ">": .slope(direction: .east)
			case "<": .slope(direction: .west)
			case "^": .slope(direction: .north)
			case "v": .slope(direction: .south)
			default: preconditionFailure()
			}
		}

		let maxX = grid.keys.map(\.x).max()!
		let maxY = grid.keys.map(\.y).max()!

		return .init(grid: grid, size: .init(width: maxX + 1, height: maxY + 1))
	}
}
