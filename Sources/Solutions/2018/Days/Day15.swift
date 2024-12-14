import Collections
import Foundation
import Tools

final class Day15Solver: DaySolver {
	let dayNumber: Int = 15

	private var shortestPathCache: [Int: [Point2D]?] = [:]

	struct Input {
		let grid: Grid
		let goblins: [Point2D]
		let elves: [Point2D]
	}

	private struct Grid {
		let walls: Set<Point2D>
		let size: Size
	}

	private enum UnitType: Equatable {
		case goblin
		case elf
	}

	private enum TurnResult {
		case moved
		case attacked
		case noEnemiesRemaining
		case noMovePossible
	}

	private enum RoundResult {
		case completed
		case noEnemiesRemaining
	}

	private final class Unit: Equatable, Hashable, CustomStringConvertible {
		let id: UUID = .init()

		let unitType: UnitType
		var position: Point2D
		var hitPoints: Int
		let attackPower: Int

		init(unitType: UnitType, position: Point2D, hitPoints: Int, attackPower: Int = 3) {
			self.unitType = unitType
			self.position = position
			self.hitPoints = hitPoints
			self.attackPower = attackPower
		}

		func isEnemyOf(_ unit: Unit) -> Bool {
			unitType != unit.unitType
		}

		var description: String {
			switch unitType {
			case .goblin: "Goblin (\(hitPoints)) @ \(position) "
			case .elf: "Elf (\(hitPoints)) @ \(position)"
			}
		}

		static func == (_ lhs: Unit, _ rhs: Unit) -> Bool {
			lhs.id == rhs.id
		}

		func hash(into hasher: inout Hasher) {
			hasher.combine(id)
		}
	}

	private final class State: Hashable {
		var units: [Unit]

		var sortedUnits: [Unit] {
			units.sorted(by: {
				let lhsPosition = $0.position
				let rhsPosition = $1.position

				return lhsPosition.y == rhsPosition.y ? lhsPosition.x < rhsPosition.x : lhsPosition.y < rhsPosition.y
			})
		}

		var numberOfElves: Int {
			units.count { $0.unitType == .elf }
		}

		var numberOfGoblins: Int {
			units.count { $0.unitType == .goblin }
		}

		init(units: [Unit]) {
			self.units = units
		}

		func unit(at position: Point2D) -> Unit? {
			units.first(where: { $0.position == position })
		}

		static func == (_ lhs: State, _ rhs: State) -> Bool {
			lhs.units == rhs.units
		}

		func hash(into hasher: inout Hasher) {
			hasher.combine(units.map(\.position))
			hasher.combine(units.map(\.unitType))
		}
	}

	private func performAttack(forUnit unit: Unit, state: State, grid: Grid) {
		var candidateUnit: Unit?

		// reading order
		let neighborPositions: [Point2D] = [
			unit.position.moved(to: .north),
			unit.position.moved(to: .west),
			unit.position.moved(to: .east),
			unit.position.moved(to: .south),
		]

		for neighbor in neighborPositions {
			guard let candidate = state.unit(at: neighbor), candidate.isEnemyOf(unit) else {
				continue
			}

			if candidateUnit == nil {
				candidateUnit = candidate
			} else if candidate.hitPoints < candidateUnit!.hitPoints {
				candidateUnit = candidate
			}
		}

		guard let candidateUnit else {
			preconditionFailure()
		}

		candidateUnit.hitPoints -= unit.attackPower

		if candidateUnit.hitPoints <= 0 {
			state.units.remove(at: state.units.firstIndex(of: candidateUnit)!)
		}
	}

	private func theoreticallyReachableSquaresFor(unit: Unit, state: State, grid: Grid) -> Set<Point2D> {
		let unitPositions: Set<Point2D> = Set(state.units.map(\.position))
		let enemyPositions: Set<Point2D> = Set(state.units.filter { $0.isEnemyOf(unit) }.map(\.position))

		let reachablePositions: Set<Point2D> = Set(enemyPositions.flatMap { $0.neighbors().filter {
			!grid.walls.contains($0) && !unitPositions.contains($0) && (0 ..< grid.size.width).contains($0.x) && (0 ..< grid.size.height).contains($0.y)
		}})

		return reachablePositions
	}

	private func shortestPathFrom(a: Point2D, toB b: Point2D, state: State, grid: Grid) -> [Point2D]? {
		struct CacheKey: Hashable {
			let a: Point2D
			let b: Point2D
			let state: State
		}

		struct Node {
			let position: Point2D
			let path: [Point2D]
		}

		let cacheKey = CacheKey(a: a, b: b, state: state).hashValue

		if let cachedValue = shortestPathCache[cacheKey] {
			return cachedValue
		}

		let unitPositions: Set<Point2D> = Set(state.units.map(\.position))

		var queue: Deque<Node> = [.init(position: a, path: [])]

		var visitedPoints: Set<Point2D> = [a]

		while let node = queue.popFirst() {
			if node.position == b {
				shortestPathCache[cacheKey] = node.path

				return node.path
			}

			// this should solve the reading order shortest path (?)
			let neighbors: [Point2D] = [
				node.position.moved(to: .north),
				node.position.moved(to: .west),
				node.position.moved(to: .east),
				node.position.moved(to: .south),
			]

			for neighbor in neighbors {
				guard
					(0 ..< grid.size.width).contains(neighbor.x),
					(0 ..< grid.size.height).contains(neighbor.y),
					!visitedPoints.contains(neighbor),
					!grid.walls.contains(neighbor),
					!unitPositions.contains(neighbor)
				else {
					continue
				}

				visitedPoints.insert(neighbor)

				queue.append(.init(position: neighbor, path: node.path + [neighbor]))
			}
		}

		shortestPathCache[cacheKey] = nil

		return nil
	}

	private func unitCanAttack(forUnit unit: Unit, state: State, grid: Grid) -> Bool {
		for neighbor in unit.position.neighbors() {
			if let unitToAttack = state.unit(at: neighbor), unit.isEnemyOf(unitToAttack) {
				return true
			}
		}

		return false
	}

	private func doTurn(forUnit unit: Unit, state: State, grid: Grid) -> TurnResult {
		if unitCanAttack(forUnit: unit, state: state, grid: grid) {
			performAttack(forUnit: unit, state: state, grid: grid)

			return .attacked
		} else {
			if state.units.count({ $0.isEnemyOf(unit) }) == 0 {
				return .noEnemiesRemaining
			}

			// find a move to do
			let theoreticallyReachablePositions = theoreticallyReachableSquaresFor(unit: unit, state: state, grid: grid)

			var practicallyReachablePositions: [Point2D: [Point2D]] = [:]

			for reachablePosition in theoreticallyReachablePositions {
				if let shortestPath = shortestPathFrom(a: unit.position, toB: reachablePosition, state: state, grid: grid) {
					practicallyReachablePositions[reachablePosition] = shortestPath
				}
			}

			guard let minNumberOfSteps = practicallyReachablePositions.values.map(\.count).min() else {
				return .noMovePossible
			}

			practicallyReachablePositions = practicallyReachablePositions.filter { $0.value.count == minNumberOfSteps }

			let targetPosition = practicallyReachablePositions.keys.sorted(by: { lhs, rhs in
				lhs.y == rhs.y ? lhs.x < rhs.x : lhs.y < rhs.y
			}).first!

			let nextPosition = practicallyReachablePositions[targetPosition]!.first!

			unit.position = nextPosition

			if unitCanAttack(forUnit: unit, state: state, grid: grid) {
				performAttack(forUnit: unit, state: state, grid: grid)

				return .attacked
			} else {
				return .moved
			}
		}
	}

	private func doRound(withState state: State, grid: Grid) -> RoundResult {
		let startingUnits = state.sortedUnits

		unitLoop: for unit in startingUnits {
			// make sure the unit isn't killed in the meantime!
			guard state.units.contains(where: { $0.id == unit.id }) else {
				continue
			}

			let turnResult = doTurn(forUnit: unit, state: state, grid: grid)

			switch turnResult {
			case .moved:
				break
			case .attacked:
				break
			case .noMovePossible:
				break
			case .noEnemiesRemaining:
				return .noEnemiesRemaining
			}
		}

		return .completed
	}

	func solvePart1(withInput input: Input) -> Int {
		let state = State(units: input.goblins.map {
			Unit(unitType: .goblin, position: $0, hitPoints: 200)
		} + input.elves.map {
			Unit(unitType: .elf, position: $0, hitPoints: 200)
		})

		var roundCounter = 0
		while true {
			let roundResult = doRound(withState: state, grid: input.grid)

			switch roundResult {
			case .completed:
				break
			case .noEnemiesRemaining:
				return roundCounter * state.units.map(\.hitPoints).reduce(0, +)
			}

			roundCounter += 1
		}
	}

	func solvePart2(withInput input: Input) -> Int {
		var attackPower = 3

		attackPowerLoop: while true {
			let state = State(units: input.goblins.map {
				Unit(unitType: .goblin, position: $0, hitPoints: 200)
			} + input.elves.map {
				Unit(unitType: .elf, position: $0, hitPoints: 200, attackPower: attackPower)
			})

			let originalNumberOfElves = state.numberOfElves

			var roundCounter = 0
			while true {
				let roundResult = doRound(withState: state, grid: input.grid)

				guard state.numberOfElves == originalNumberOfElves else {
					attackPower += 1

					continue attackPowerLoop
				}

				switch roundResult {
				case .completed:
					break
				case .noEnemiesRemaining:
					return roundCounter * state.units.map(\.hitPoints).reduce(0, +)
				}

				roundCounter += 1
			}
		}
	}

	func parseInput(rawString: String) -> Input {
		var walls: Set<Point2D> = []
		var goblins: [Point2D] = []
		var elves: [Point2D] = []
		var size: Size = .zero

		_ = rawString.parseGrid { character, point in
			switch character {
			case ".": break
			case "#": walls.insert(point)
			case "E": elves.append(point)
			case "G": goblins.append(point)
			default: preconditionFailure()
			}

			size = .init(width: max(size.width, point.x + 1), height: max(size.height, point.y + 1))
		}

		return .init(grid: .init(walls: walls, size: size), goblins: goblins, elves: elves)
	}
}
