import Collections
import Foundation
import Tools

final class Day16Solver: DaySolver {
	let dayNumber: Int = 16

	struct Input {
		let grid: Grid2D<Tile>
		let start: Point2D
		let end: Point2D
	}

	enum Tile: Equatable {
		case empty
		case wall
	}

	private enum Move {
		case rotate(direction: Direction)
		case moveForward
	}

	/// relaxed: true means include equal scoring paths instead of just the best scoring path
	private func findShortestPath(in grid: Grid2D<Tile>, start: Point2D, end: Point2D, relaxed: Bool) -> [(path: Set<Point2D>, score: Int)] {
		struct Node: Comparable {
			var position: Point2D
			var direction: Direction
			var score: Int
			var history: Set<Point2D>

			static func < (lhs: Node, rhs: Node) -> Bool {
				lhs.score < rhs.score
			}
		}

		struct ScoreKey: Hashable {
			let position: Point2D
			let direction: Direction
		}

		var priorityQueue = PriorityQueue<Node>(isAscending: true)

		priorityQueue.push(Node(position: start, direction: .east, score: 0, history: [start]))

		var scores: [Int: Int] = [
			ScoreKey(position: start, direction: .east).hashValue: 0,
		]

		var shortestPaths: [(path: Set<Point2D>, score: Int)] = []

		while let node = priorityQueue.pop() {
			if node.position == end {
				shortestPaths.append((path: node.history, score: node.score))

				continue
			}

			let forwardPosition = node.position.moved(to: node.direction)
			let leftDirection = node.direction.left
			let rightDirection = node.direction.right
			let leftPosition = node.position.moved(to: leftDirection)
			let rightPosition = node.position.moved(to: rightDirection)

			var possibleNextNodes: [Node] = []

			if !node.history.contains(forwardPosition), let forwardTile = grid[safe: forwardPosition], forwardTile == .empty {
				possibleNextNodes.append(Node(position: forwardPosition, direction: node.direction, score: node.score + 1, history: node.history.union([forwardPosition])))
			}

			if !node.history.contains(leftPosition), let tile = grid[safe: leftPosition], tile == .empty {
				possibleNextNodes.append(Node(position: node.position, direction: leftDirection, score: node.score + 1000, history: node.history))
			}

			if !node.history.contains(leftPosition), let tile = grid[safe: rightPosition], tile == .empty {
				possibleNextNodes.append(Node(position: node.position, direction: rightDirection, score: node.score + 1000, history: node.history))
			}

			for possibleNextNode in possibleNextNodes {
				let scoreHash = ScoreKey(position: possibleNextNode.position, direction: possibleNextNode.direction).hashValue

				let oldScore = scores[scoreHash]

				if oldScore == nil || possibleNextNode.score < (oldScore! + (relaxed ? 1 : 0)) {
					scores[scoreHash] = possibleNextNode.score

					priorityQueue.push(possibleNextNode)
				}
			}
		}

		return shortestPaths
	}

	func solvePart1(withInput input: Input) -> Int {
		findShortestPath(in: input.grid, start: input.start, end: input.end, relaxed: false)[0].score
	}

	func solvePart2(withInput input: Input) -> Int {
		let paths = findShortestPath(in: input.grid, start: input.start, end: input.end, relaxed: true)

		var finalPoints: Set<Point2D> = []

		for path in paths {
			finalPoints.formUnion(path.path)
		}

		return finalPoints.count
	}

	func parseInput(rawString: String) -> Input {
		var start: Point2D = .zero
		var end: Point2D = .zero

		let grid: Grid2D<Tile> = rawString.parseGrid2D { character, point in
			switch character {
			case "S":
				start = point
				return .empty
			case "E":
				end = point
				return .empty
			case ".":
				return .empty
			case "#": return .wall
			default: preconditionFailure()
			}
		}

		return .init(grid: grid, start: start, end: end)
	}
}
