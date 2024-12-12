import Collections
import Foundation
import Tools

final class Day23Solver: DaySolver {
	let dayNumber: Int = 23

	private var input: Input!

	// cache solution to facilitate visualizer
	private var part2Solution: (startState: GameState, endState: GameState)!

	private struct Input {
		let rooms: [Room]
	}

	private enum Amphipod: Int, Equatable, Hashable, RawRepresentable {
		case none = 0
		case amber = 1
		case bronze = 2
		case copper = 3
		case desert = 4

		var stepCost: Int {
			switch self {
			case .none: fatalError()
			case .amber: 1
			case .bronze: 10
			case .copper: 100
			case .desert: 1000
			}
		}
	}

	private struct Hallway: Hashable {
		var cells: [Amphipod] = Array(repeating: .none, count: 11)

		func canMove(from: Int, to: Int, toRoom: Int? = nil, gameState: GameState) -> Bool {
			guard from != to else {
				return false
			}

			if let toRoom, 2 + toRoom * 2 != to {
				return false
			}

			if from < to {
				return gameState.hallway.cells[from + 1 ... to].allSatisfy { $0 == .none }
			} else {
				return gameState.hallway.cells[to ..< from].allSatisfy { $0 == .none }
			}
		}
	}

	private struct Room: Hashable {
		let amphipod: Amphipod

		var cells: [Amphipod] // 0 is top (closest to hallways)

		var isReadyToMoveIn: Bool {
			cells.allSatisfy { $0 == .none || $0 == amphipod }
		}

		var isComplete: Bool {
			cells.allSatisfy { $0 == amphipod }
		}

		func canGetOutOfRoom(at index: Int) -> Bool {
			cells[0 ..< index].allSatisfy { $0 == .none }
		}

		func possibleMoveIndex(for amphipod: Amphipod) -> Int? {
			guard self.amphipod == amphipod, isReadyToMoveIn, isComplete == false else {
				return nil
			}

			for index in (0 ..< cells.count).reversed() {
				if cells[index] == .none {
					return index
				}
			}

			return nil
		}
	}

	private struct GameState: Hashable {
		let hallway: Hallway
		let rooms: [Room]

		let totalCost: Int

		let moves: [Move]

		let cacheKey: UInt64

		let isComplete: Bool

		func hash(into hasher: inout Hasher) {
			hasher.combine(hallway)
			hasher.combine(rooms)
		}

		static func == (_ lhs: GameState, _ rhs: GameState) -> Bool {
			lhs.hashValue == rhs.hashValue
		}

		init(hallway: Hallway, rooms: [Room], totalCost: Int, moves: [Move]) {
			self.hallway = hallway
			self.rooms = rooms
			self.totalCost = totalCost
			self.moves = moves

			var cacheKey: UInt64 = 0

			// we only move to 0, 1, 3, 5, 7, 9, 10 so only need to include those in cache key

			cacheKey = (cacheKey * 5) + UInt64(hallway.cells[0].rawValue)
			cacheKey = (cacheKey * 5) + UInt64(hallway.cells[1].rawValue)
			cacheKey = (cacheKey * 5) + UInt64(hallway.cells[3].rawValue)
			cacheKey = (cacheKey * 5) + UInt64(hallway.cells[5].rawValue)
			cacheKey = (cacheKey * 5) + UInt64(hallway.cells[7].rawValue)
			cacheKey = (cacheKey * 5) + UInt64(hallway.cells[9].rawValue)
			cacheKey = (cacheKey * 5) + UInt64(hallway.cells[10].rawValue)

			for roomIndex in 0 ..< 3 {
				for cell in rooms[roomIndex].cells {
					cacheKey = (cacheKey * 5) + UInt64(cell.rawValue)
				}
			}

			self.cacheKey = cacheKey

			isComplete = rooms.allSatisfy(\.isComplete)
		}
	}

	private enum Spot: Equatable {
		case hallway(index: Int)
		case room(index: Int, cellIndex: Int)
	}

	private struct Move: Equatable {
		let who: Amphipod

		let from: Spot
		let to: Spot

		let cost: Int

		init(who: Amphipod, from: Spot, to: Spot) {
			self.who = who
			self.from = from
			self.to = to

			var hallwayFromPosition = 0
			var hallwayToPosition = 0

			var roomSteps = 0

			switch from {
			case .room(let roomIndex, let cellIndex):
				roomSteps += cellIndex + 1
				hallwayFromPosition = 2 + (roomIndex * 2)
			case .hallway(let index):
				hallwayFromPosition = index
			}

			switch to {
			case .room(let roomIndex, let cellIndex):
				roomSteps += cellIndex + 1
				hallwayToPosition = 2 + (roomIndex * 2)
			case .hallway(let index):
				hallwayToPosition = index
			}

			let steps = roomSteps + abs(hallwayToPosition - hallwayFromPosition)

			cost = steps * who.stepCost
		}
	}

	private func possibleMovesFor(spot: Spot, gameState: GameState, container: inout [Move]) {
		switch spot {
		case .room(let currentRoomIndex, let cellIndex):
			let room = gameState.rooms[currentRoomIndex]
			let who = room.cells[cellIndex]

			guard
				who != .none,
				room.isComplete == false,
				room.cells[cellIndex ..< room.cells.endIndex].allSatisfy({ $0 == room.amphipod }) == false,
				room.canGetOutOfRoom(at: cellIndex)
			else {
				return
			}

			var foundRoomSpots = false

			for roomIndex in 0 ..< 4 where roomIndex != currentRoomIndex {
				let toRoom = gameState.rooms[roomIndex]

				guard toRoom.isComplete == false, let targetCellIndex = toRoom.possibleMoveIndex(for: who) else {
					continue
				}

				if gameState.hallway.canMove(from: 2 + (currentRoomIndex * 2), to: 2 + (roomIndex * 2), toRoom: roomIndex, gameState: gameState) {
					container.append(.init(who: who, from: spot, to: .room(index: roomIndex, cellIndex: targetCellIndex)))

					foundRoomSpots = true
				}
			}

			// only look for hallway spots in case we can't go directly to a room
			if foundRoomSpots == false {
				for toIndex in [0, 1, 3, 5, 7, 9, 10] {
					if gameState.hallway.canMove(from: 2 + (currentRoomIndex * 2), to: toIndex, toRoom: nil, gameState: gameState) {
						container.append(.init(who: who, from: spot, to: .hallway(index: toIndex)))
					}
				}
			}

		case .hallway(let index):
			let who = gameState.hallway.cells[index]

			guard who != .none else {
				return
			}

			for roomIndex in 0 ..< 4 {
				guard let targetCellIndex = gameState.rooms[roomIndex].possibleMoveIndex(for: who) else {
					continue
				}

				if gameState.hallway.canMove(from: index, to: 2 + (roomIndex * 2), toRoom: roomIndex, gameState: gameState) {
					container.append(.init(who: who, from: spot, to: .room(index: roomIndex, cellIndex: targetCellIndex)))
				}
			}
		}
	}

	private func executeMove(_ move: Move, on gameState: GameState) -> GameState {
		var newRooms = gameState.rooms
		var newHallway = gameState.hallway

		let who: Amphipod

		switch move.from {
		case .room(let roomIndex, let index):
			who = newRooms[roomIndex].cells[index]

			newRooms[roomIndex].cells[index] = .none
		case .hallway(let index):
			who = newHallway.cells[index]

			newHallway.cells[index] = .none
		}

		switch move.to {
		case .room(let roomIndex, let index):
			newRooms[roomIndex].cells[index] = who
		case .hallway(let index):
			newHallway.cells[index] = who
		}

		return .init(hallway: newHallway, rooms: newRooms, totalCost: gameState.totalCost + move.cost, moves: gameState.moves + [move])
	}

	private func solve(with originalGameState: GameState, roomSize: Int = 2) -> GameState? {
		var queue: Deque<GameState> = []

		queue.append(originalGameState)

		var bestGameState: GameState?
		var bestCost = Int.max

		var minimumCosts: [UInt64: Int] = [:]

		var possibleMoves: [Move] = Array()

		possibleMoves.reserveCapacity(100)

		while let gameState = queue.popFirst() {
			possibleMoves.removeAll(keepingCapacity: true)

			for roomIndex in 0 ... 3 {
				for cellIndex in 0 ..< roomSize {
					possibleMovesFor(spot: .room(index: roomIndex, cellIndex: cellIndex), gameState: gameState, container: &possibleMoves)
				}
			}

			for hallwayIndex in [0, 1, 3, 5, 7, 9, 10] {
				possibleMovesFor(spot: .hallway(index: hallwayIndex), gameState: gameState, container: &possibleMoves)
			}

			for move in possibleMoves where gameState.totalCost + move.cost < bestCost {
				let newGameState = executeMove(move, on: gameState)

				if minimumCosts[newGameState.cacheKey, default: Int.max] < newGameState.totalCost {
					continue
				}

				minimumCosts[newGameState.cacheKey] = newGameState.totalCost

				if newGameState.isComplete {
					if let currentBestGameState = bestGameState {
						if newGameState.totalCost < currentBestGameState.totalCost {
							bestGameState = newGameState
							bestCost = newGameState.totalCost
						}
					} else {
						bestGameState = newGameState
						bestCost = newGameState.totalCost
					}

					continue
				} else {
					queue.insert(newGameState, at: 0)
				}
			}
		}

		return bestGameState
	}

	func solvePart1() -> Int {
		let initialGameState = GameState(hallway: .init(), rooms: input.rooms, totalCost: 0, moves: [])

		let bestGameState = solve(with: initialGameState)!

		return bestGameState.totalCost
	}

	func solvePart2() -> Int {
		var rooms = input.rooms

		rooms[0].cells.insert(.desert, at: 1)
		rooms[0].cells.insert(.desert, at: 2)
		rooms[1].cells.insert(.copper, at: 1)
		rooms[1].cells.insert(.bronze, at: 2)
		rooms[2].cells.insert(.bronze, at: 1)
		rooms[2].cells.insert(.amber, at: 2)
		rooms[3].cells.insert(.amber, at: 1)
		rooms[3].cells.insert(.copper, at: 2)

		let initialGameState = GameState(hallway: .init(), rooms: rooms, totalCost: 0, moves: [])

		let bestGameState = solve(with: initialGameState, roomSize: 4)!

		part2Solution = (startState: initialGameState, endState: bestGameState)

		return bestGameState.totalCost
	}

	func parseInput(rawString: String) {
		input = .init(rooms: [
			.init(amphipod: .amber, cells: [.amber, .desert]),
			.init(amphipod: .bronze, cells: [.copper, .desert]),
			.init(amphipod: .copper, cells: [.bronze, .bronze]),
			.init(amphipod: .desert, cells: [.amber, .copper]),
		])
	}
}

//extension Day23Solver {
//	func createVisualizer() -> Visualizer? {
//		StepsVisualizer(solver: self)
//	}
//
//	final class StepsVisualizer: Visualizer {
//		let solver: any DaySolver
//
//		var dimensions: Size {
//			.init(width: 15 * 16, height: 9 * 16)
//		}
//
//		var frameDescription: String?
//
//		var isCompleted: Bool = false
//
//		init(solver: Day23Solver) {
//			self.solver = solver
//		}
//
//		func renderFrame(with context: VisualizationContext) {
//			context.startNewFrame()
//
//			enum GridElement {
//				case wall
//				case path
//				case amphipod(Amphipod)
//				case empty
//			}
//
//			enum MoveStage: Int {
//				case nothing
//				case highlightOld
//				case highlightNew
//				case move
//			}
//
//			var grid: [[GridElement]] = [
//				[.wall, .wall, .wall, .wall, .wall, .wall, .wall, .wall, .wall, .wall, .wall, .wall, .wall],
//				[.wall, .empty, .path, .path, .path, .path, .path, .path, .path, .path, .path, .path, .wall],
//				[.wall, .wall, .wall, .empty, .wall, .empty, .wall, .empty, .wall, .empty, .wall, .wall, .wall],
//				[.empty, .empty, .wall, .empty, .wall, .empty, .wall, .empty, .wall, .empty, .wall, .empty, .empty],
//				[.empty, .empty, .wall, .empty, .wall, .empty, .wall, .empty, .wall, .empty, .wall, .empty, .empty],
//				[.empty, .empty, .wall, .empty, .wall, .empty, .wall, .empty, .wall, .empty, .wall, .empty, .empty],
//				[.empty, .empty, .wall, .wall, .wall, .wall, .wall, .wall, .wall, .wall, .wall, .empty, .empty],
//			]
//
//			let solver = solver as! Day23Solver
//
//			let part2Solution = solver.part2Solution!
//
//			var gameState = part2Solution.startState
//			let endState = part2Solution.endState
//
//			let moveStage = MoveStage(rawValue: context.frameCounter % 4)!
//			let moveIndex = context.frameCounter / 4
//
//			var cost = 0
//
//			let currentMove = endState.moves[moveIndex]
//
//			for i in 0 ..< min(moveIndex, endState.moves.count) {
//				gameState = solver.executeMove(endState.moves[i], on: gameState)
//
//				cost += endState.moves[i].cost
//			}
//
//			if moveStage == .move {
//				gameState = solver.executeMove(currentMove, on: gameState)
//
//				cost += currentMove.cost
//			}
//
//			for (index, cell) in gameState.hallway.cells.enumerated() {
//				grid[1][1 + index] = .amphipod(cell)
//			}
//
//			for (roomIndex, room) in gameState.rooms.enumerated() {
//				for (cellIndex, cell) in room.cells.enumerated() {
//					grid[2 + cellIndex][3 + (roomIndex * 2)] = .amphipod(cell)
//				}
//			}
//
//			let elementSize = 15
//
//			func rectFor(rowIndex: Int, columnIndex: Int) -> Rect {
//				.init(
//					origin: .init(
//						x: columnIndex * (elementSize + 1),
//						y: rowIndex * (elementSize + 1)
//					),
//					size: .init(
//						width: elementSize,
//						height: elementSize
//					)
//				)
//			}
//
//			for (rowIndex, row) in grid.enumerated() {
//				for (columnIndex, cell) in row.enumerated() {
//					let color: Color
//
//					switch cell {
//					case .empty:
//						color = .black
//					case .path:
//						color = .dimGray
//					case .amphipod(let amphipod):
//						switch amphipod {
//						case .desert: color = .desert
//						case .amber: color = .amber
//						case .bronze: color = .bronze
//						case .copper: color = .copper
//						case .none: color = .dimGray
//						}
//					case .wall:
//						color = .white
//					}
//
//					context.fillRect(rectFor(rowIndex: rowIndex + 1, columnIndex: columnIndex + 1), color: color)
//
//					let textPoint = Point2D(
//						x: (columnIndex + 1) * (elementSize + 1) + 5,
//						y: (rowIndex + 1) * (elementSize + 1) + 4
//					)
//
//					if case .amphipod(let amphipod) = cell {
//						switch amphipod {
//						case .desert: context.drawText("D", at: textPoint, color: .black)
//						case .amber: context.drawText("A", at: textPoint, color: .black)
//						case .bronze: context.drawText("B", at: textPoint, color: .black)
//						case .copper: context.drawText("C", at: textPoint, color: .black)
//						case .none: break
//						}
//					}
//				}
//			}
//
//			frameDescription = "Total Cost: \(cost)"
//
//			var highlights: [(Int, Int)] = []
//
//			switch moveStage {
//			case .move:
//				if moveIndex == endState.moves.count - 1 {
//					isCompleted = true
//
//					return
//				}
//
//				fallthrough
//			case .highlightNew:
//				switch currentMove.to {
//				case .room(let index, let cellIndex):
//					highlights.append((2 + cellIndex, 3 + index * 2))
//				case .hallway(let index):
//					highlights.append((1, 1 + index))
//				}
//				fallthrough
//			case .highlightOld:
//				switch currentMove.from {
//				case .room(let index, let cellIndex):
//					highlights.append((2 + cellIndex, 3 + index * 2))
//				case .hallway(let index):
//					highlights.append((1, 1 + index))
//				}
//			case .nothing:
//				break
//			}
//
//			for highlight in highlights {
//				let rect = rectFor(rowIndex: highlight.0 + 1, columnIndex: highlight.1 + 1)
//
//				context.drawRect(rect, width: 2, color: .hotPink)
//			}
//		}
//	}
//}
