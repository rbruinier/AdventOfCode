import Collections
import Foundation
import Tools

/// Two step solution where we first find the distance between all numbers (paths) basically building a graph and then perform a second iteration to find the shortest path through the graph.
/// In both cases BFS is used.
final class Day24Solver: DaySolver {
	let dayNumber: Int = 24

	typealias Grid = [Point2D: Node]

	struct Input {
		let grid: Grid
	}

	enum Node: Equatable {
		case wall
		case free
		case position(number: Int)
	}

	private var allNumbers: [Int]!
	private var graph: WeightedGraph!

	private func possibleNextPositions(for position: Point2D, grid: Grid) -> [Point2D] {
		position.neighbors().filter { point in
			grid[point] != .wall
		}
	}

	private func position(of number: Int, in grid: Grid) -> Point2D {
		grid.first(where: { _, value in
			value == .position(number: number)
		})!.key
	}

	private func minimumNumberOfRequiredSteps(from pointA: Point2D, to pointB: Point2D, in grid: Grid) -> Int {
		struct GridWrapper: Tools.BFSGrid {
			let grid: Grid

			func reachableNeighborsAt(position: Point2D) -> [Point2D] {
				position.neighbors().filter { point in
					grid[point]! != .wall
				}
			}
		}

		let bfsGrid = GridWrapper(grid: grid)

		return BFS.shortestPathInGrid(bfsGrid, from: pointA, to: pointB)!.steps
	}

	private func graph(for numbers: [Int], in grid: Grid) -> WeightedGraph {
		var edges: [WeightedGraph.Edge] = []

		for i in 0 ..< numbers.count {
			let pointA = position(of: numbers[i], in: grid)

			for j in i + 1 ..< numbers.count {
				let pointB = position(of: numbers[j], in: grid)

				let steps = minimumNumberOfRequiredSteps(from: pointA, to: pointB, in: grid)

				edges.append(.init(a: i, b: j, weight: steps))
			}
		}

		return .init(elementsCount: numbers.count, edges: edges)
	}

	func solvePart1(withInput input: Input) -> Int {
		let grid = input.grid

		allNumbers = grid.compactMap { _, value in
			if case .position(let number) = value {
				number
			} else {
				nil
			}
		}.sorted()

		graph = graph(for: allNumbers, in: grid)

		return BFS.visitAllElementsInGraph(graph, returnToStart: false)!.pathWeight
	}

	func solvePart2(withInput input: Input) -> Int {
		BFS.visitAllElementsInGraph(graph, returnToStart: true)!.pathWeight
	}

	func parseInput(rawString: String) -> Input {
		var grid: [Point2D: Node] = [:]

		for (y, line) in rawString.allLines().enumerated() {
			for (x, field) in line.enumerated() {
				let node: Node

				switch field {
				case "#":
					node = .wall
				case ".":
					node = .free
				default:
					node = .position(number: Int(String(field))!)
				}

				grid[.init(x: x, y: y)] = node
			}
		}

		return .init(grid: grid)
	}
}
