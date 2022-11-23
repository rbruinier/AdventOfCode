import Collections
import Foundation

public protocol BFSGrid {
	func reachableNeighborsAt(position: Point2D) -> [Point2D]
}

/// Various solvers using the BFS strategy
public enum BFS {}

// MARK: - Shortest path in grid from A to B

public extension BFS {
	struct ShortestPathInGridResult {
		/// The full path from point A to point B.
		public let path: [Point2D]

		/// The total number of steps required to get from point A to point B in the grid.
		public let steps: Int
	}

	private struct ShortestPathInGridQueueNode {
		let position: Point2D
		let visitedPoints: [Point2D]
		let steps: Int
	}

	/// Tries to find the shortest path in a grid from point A to B.
	/// - Parameters:
	///   - grid: The grid to find the path in.
	///   - pointA: Starting point in the grid. Should be an accessible grid point.
	///   - pointB: End point in the grid. Should be an accessible grid point.
	/// - Returns: The solution when available.
	static func shortestPathInGrid(grid: some BFSGrid, from pointA: Point2D, to pointB: Point2D) -> ShortestPathInGridResult? {
		var solutionQueue: Deque<ShortestPathInGridQueueNode> = [
			.init(position: pointA, visitedPoints: [pointA], steps: 0),
		]

		var bestSolution: ShortestPathInGridQueueNode?

		var visitedPoints: Set<Point2D> = [pointA]

		while let solution = solutionQueue.popFirst() {
			if solution.position == pointB {
				bestSolution = solution

				break
			}

			let possiblePoints = grid.reachableNeighborsAt(position: solution.position) // possibleNextPositions(for: solution.currentPosition, grid: grid)

			for nextPoint in possiblePoints where visitedPoints.contains(nextPoint) == false {
				visitedPoints.insert(nextPoint)

				solutionQueue.append(
					.init(
						position: nextPoint,
						visitedPoints: solution.visitedPoints + [nextPoint],
						steps: solution.steps + 1
					)
				)
			}
		}

		guard let bestSolution else {
			return nil
		}

		return .init(path: bestSolution.visitedPoints, steps: bestSolution.steps)
	}
}

// MARK: - Visit all elements in a Graph

public extension BFS {
	struct VisitAllElementsResult {
		public let pathIndices: [WeightedGraph.ElementIndex]
		public let pathWeight: WeightedGraph.Weight
	}

	private struct VisitAllElementsQueueNode {
		let index: WeightedGraph.ElementIndex
		let visitedIndices: [WeightedGraph.ElementIndex]
		let combinedWeight: WeightedGraph.Weight
	}

	/// Visits all connected elements in a graph with the shortest path possible.
	/// - Parameters:
	///   - graph: The graph.
	///   - rootIndex: The index of the element to start at.
	///   - returnToStart: Include the start element as a last element (path becomes a loop)
	/// - Returns: The result if available.
	static func visitAllElements(in graph: WeightedGraph<some Any>, startingAtIndex rootIndex: Int = 0, returnToStart: Bool = false) -> VisitAllElementsResult? {
		var solutionQueue: Deque<VisitAllElementsQueueNode> = [
			.init(index: rootIndex, visitedIndices: [rootIndex], combinedWeight: 0),
		]

		var bestSolution: VisitAllElementsQueueNode?

		while let solution = solutionQueue.popFirst() {
			if solution.visitedIndices.count == graph.count + (returnToStart ? 1 : 0) {
				if let currentBestSolution = bestSolution {
					if solution.combinedWeight < currentBestSolution.combinedWeight {
						bestSolution = solution
					}
				} else {
					bestSolution = solution
				}

				continue
			}

			let edges = graph.directionalEdges(from: solution.index)

			for edge in edges {
				if returnToStart, solution.visitedIndices.count == graph.count {
					guard edge.b == rootIndex else {
						continue
					}
				} else {
					guard solution.visitedIndices.contains(edge.b) == false else {
						continue
					}
				}

				if let bestSolution, (solution.combinedWeight + edge.weight) >= bestSolution.combinedWeight {
					continue
				}

				solutionQueue.append(
					.init(
						index: edge.b,
						visitedIndices: solution.visitedIndices + [edge.b],
						combinedWeight: solution.combinedWeight + edge.weight
					)
				)
			}
		}

		guard let bestSolution else {
			return nil
		}

		return .init(pathIndices: bestSolution.visitedIndices, pathWeight: bestSolution.combinedWeight)
	}
}
