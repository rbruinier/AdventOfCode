import Collections
import Foundation
import Tools

final class Day22Solver: DaySolver {
	let dayNumber: Int = 22

	private var input: Input!

	private struct Input {
		let depth: Int
		let target: Point2D
	}

	private enum Tile: Hashable {
		case rocky
		case wet
		case narrow

		var riskLevel: Int {
			switch self {
			case .rocky: 0
			case .wet: 1
			case .narrow: 2
			}
		}
	}

	private func createGridWithSize(_ size: Size, depth: Int) -> Grid2D<Tile> {
		var erosionLevels: [[Int]] = .init(repeating: .init(repeating: 0, count: size.width), count: size.height)

		let moduloValue = 20183

		for x in 0 ..< size.width {
			erosionLevels[0][x] = ((x * 16807) + depth) % moduloValue
		}

		for y in 0 ..< size.height {
			erosionLevels[y][0] = ((y * 48271) + depth) % moduloValue
		}

		erosionLevels[0][0] = depth % moduloValue
		erosionLevels[input.target.y][input.target.x] = depth % moduloValue

		for y in 1 ..< size.height {
			for x in 1 ..< size.width {
				guard !(input.target.y == y && input.target.x == x) else {
					continue
				}

				erosionLevels[y][x] = ((erosionLevels[y][x - 1] * erosionLevels[y - 1][x]) + depth) % moduloValue
			}
		}

		return .init(
			tiles: erosionLevels.map {
				$0.map { erosionLevel in
					switch erosionLevel % 3 {
					case 0: .rocky
					case 1: .wet
					case 2: .narrow
					default: preconditionFailure()
					}
				}
			},
			dimensions: size
		)
	}

	func solvePart1() -> Int {
		let size = Size(width: input.target.x + 1, height: input.target.y + 1)

		let grid = createGridWithSize(size, depth: input.depth)

		return grid.tiles.flatMap { $0 }.reduce(into: 0) { result, tile in
			result += tile.riskLevel
		}
	}

	private enum EquippedState: Hashable {
		case none
		case torch
		case climbingGear
	}

	private struct State: Hashable {
		let equippedState: EquippedState
		let position: Point2D
	}

	// Solve with Dijkstra
	private func findShortestPath(from startState: State, to target: Point2D, in grid: Grid2D<Tile>) -> Int {
		struct Node: Comparable {
			let equippedState: EquippedState
			let position: Point2D
			let weight: Int

			static func < (lhs: Node, rhs: Node) -> Bool {
				lhs.weight < rhs.weight
			}
		}

		struct CurrentNextKey: Hashable {
			let current: Tile
			let next: Tile
		}

		let possibleEquippedStates: [CurrentNextKey: Set<EquippedState>] = [
			.init(current: .rocky, next: .rocky): [.torch, .climbingGear],
			.init(current: .rocky, next: .wet): [.climbingGear],
			.init(current: .rocky, next: .narrow): [.torch],
			.init(current: .wet, next: .rocky): [.climbingGear],
			.init(current: .wet, next: .wet): [.climbingGear, .none],
			.init(current: .wet, next: .narrow): [.none],
			.init(current: .narrow, next: .rocky): [.torch],
			.init(current: .narrow, next: .wet): [.none],
			.init(current: .narrow, next: .narrow): [.none, .torch],
		]

		let xRange = 0 ..< grid.dimensions.width
		let yRange = 0 ..< grid.dimensions.height

		var priorityQueue = PriorityQueue<Node>(isAscending: true)

		var weights: [Int: Int] = [
			startState.hashValue: 0,
		]

		priorityQueue.push(.init(equippedState: startState.equippedState, position: startState.position, weight: 0))

		while let node = priorityQueue.pop() {
			guard let currentWeight = weights[State(equippedState: node.equippedState, position: node.position).hashValue] else {
				preconditionFailure()
			}

			if node.position == target {
				return node.weight
			}

			let currentTile = grid.tiles[node.position.y][node.position.x]

			for neighbor in node.position.neighbors() where xRange.contains(neighbor.x) && yRange.contains(neighbor.y) {
				let neighborTile = grid.tiles[neighbor.y][neighbor.x]

				for nextEquippedState in possibleEquippedStates[.init(current: currentTile, next: neighborTile)]! {
					let stateHash = State(equippedState: nextEquippedState, position: neighbor).hashValue

					var newWeight = currentWeight + (nextEquippedState == node.equippedState ? 1 : 8)

					if neighbor == target, nextEquippedState != .torch {
						newWeight += 7 // take switch to torch into account
					}

					let oldWeight = weights[stateHash]

					if oldWeight == nil || newWeight < oldWeight! {
						weights[stateHash] = newWeight

						priorityQueue.push(.init(equippedState: nextEquippedState, position: neighbor, weight: newWeight))
					}
				}
			}
		}

		return 0
	}

	func solvePart2() -> Int {
		// twice the size in each direction, assuming this is enough (must be, right?!)
		let size = Size(width: input.target.x * 2 + 1, height: input.target.y * 2 + 1)

		let grid = createGridWithSize(size, depth: input.depth)

		let startState = State(equippedState: .torch, position: .zero)

		return findShortestPath(from: startState, to: input.target, in: grid)
	}

	func parseInput(rawString: String) {
		let lines = rawString.allLines()

		input = .init(
			depth: Int(lines[0].components(separatedBy: ": ")[1])!,
			target: Point2D(commaSeparatedString: lines[1].components(separatedBy: ": ")[1])
		)
	}
}
