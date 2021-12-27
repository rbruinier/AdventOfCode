import Foundation

final class Day23Solver: DaySolver {
    let dayNumber: Int = 23

    private var input: Input!

    private struct Input {
        let rooms: [Room]
    }

    private enum Amphipod: Int, Equatable, Hashable, RawRepresentable {
        case none
        case amber
        case bronze
        case copper
        case desert

        var stepCost: Int {
            switch self {
            case .none: fatalError()
            case .amber: return 1
            case .bronze: return 10
            case .copper: return 100
            case .desert: return 1000
            }
        }
    }

    private struct Hallway: CustomStringConvertible {
        var cells: [Amphipod] = Array(repeating: .none, count: 11)

        var description: String {
            return "[" + cells.map { String($0.rawValue) }.joined() + "]"
        }

        func canMove(from: Int, to: Int, toRoom: Int? = nil, gameState: GameState) -> Bool {
            guard from != to else {
                return false
            }

            var possibleToIndices: [Int]

            if let toRoom = toRoom {
                possibleToIndices = [2 + toRoom * 2]
            } else {
                possibleToIndices = [0, 1, 3, 5, 7, 9, 10]
            }

            guard possibleToIndices.contains(to) else {
                return false
            }

            if from < to {
                return gameState.hallway.cells[from + 1 ... to].allSatisfy({ $0 == .none })
            } else {
                return gameState.hallway.cells[to ..< from].allSatisfy({ $0 == .none })
            }
        }
    }

    private struct Room: CustomStringConvertible {
        let amphipod: Amphipod

        var cells: [Amphipod] // 0 is top (closst to halways

        public var description: String {
            "[" + cells.map { String($0.rawValue) }.joined() + "]"
        }

        var isReadyToMoveIn: Bool {
            cells.allSatisfy { $0 == .none || $0 == amphipod }
        }

        var isComplete: Bool {
            cells.allSatisfy { $0 == amphipod }
        }

        func canGetOutOfRoom(at index: Int) -> Bool {
            return cells[0 ..< index].allSatisfy { $0 == .none }
        }

        func possibleMoveIndex(for amphipod: Amphipod) -> Int? {
            guard self.amphipod == amphipod, self.isReadyToMoveIn, self.isComplete == false else {
                return nil
            }

            return cells.enumerated().compactMap {
                $1 == .none ? $0 : nil
            }.max()
        }
    }

    private struct GameState {
        let hallway: Hallway
        let rooms: [Room]

        let totalCost: Int

        var cacheKey: String {
            hallway.description + "-" + rooms.map { $0.description }.joined()
        }

        var isComplete: Bool {
            return rooms.allSatisfy { $0.isComplete }
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

        var cost: Int {
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

            return steps * who.stepCost
        }
    }

    private func possibleMovesFor(spot: Spot, gameState: GameState) -> [Move] {
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
                return []
            }

            var toSpots: [Spot] = []

            for (roomIndex, toRoom) in gameState.rooms.enumerated() where roomIndex != currentRoomIndex && toRoom.isComplete == false {
                guard let targetCellIndex = toRoom.possibleMoveIndex(for: who) else {
                    continue
                }

                if gameState.hallway.canMove(from: 2 + (currentRoomIndex * 2), to: 2 + (roomIndex * 2), toRoom: roomIndex, gameState: gameState) {
                    toSpots.append(.room(index: roomIndex, cellIndex: targetCellIndex))
                }
            }

            // only look for hallway spots in case we can't go directly to a room
            if toSpots.isEmpty {
                for toIndex in 0 ... 10 {
                    if gameState.hallway.canMove(from: 2 + (currentRoomIndex * 2), to: toIndex, toRoom: nil, gameState: gameState) {
                        toSpots.append(.hallway(index: toIndex))
                    }
                }
            }

            return toSpots.map { Move(who: who, from: spot, to: $0) }
        case .hallway(let index):
            let who = gameState.hallway.cells[index]

            guard who != .none else {
                return []
            }

            var toSpots: [Spot] = []

            for (roomIndex, room) in gameState.rooms.enumerated() {
                guard let targetCellIndex = room.possibleMoveIndex(for: who) else {
                    continue
                }

                if gameState.hallway.canMove(from: index, to: 2 + (roomIndex * 2), toRoom: roomIndex, gameState: gameState) {
                    toSpots.append(.room(index: roomIndex, cellIndex: targetCellIndex))
                }
            }

            return toSpots.map { Move(who: who, from: spot, to: $0) }
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

        return .init(hallway: newHallway, rooms: newRooms, totalCost: gameState.totalCost + move.cost)
    }

    // returns lowest cost for move and subsequent moves with memoization
    private func playAllNextPossibleMoves(with gameState: GameState, stateCostCache: inout [String: Int]) -> Int {
        if gameState.isComplete { // \ 0 /
            return 0
        }

        if let minimumCosts = stateCostCache[gameState.cacheKey] {
            return minimumCosts
        }

        var possibleMoves: [Move] = []

        for roomIndex in (0 ... 3) {
            for cellIndex in 0 ..< gameState.rooms[roomIndex].cells.endIndex {
                possibleMoves += possibleMovesFor(spot: .room(index: roomIndex, cellIndex: cellIndex), gameState: gameState)
            }
        }

        for hallwayIndex in (0 ... 10) {
            possibleMoves += possibleMovesFor(spot: .hallway(index: hallwayIndex), gameState: gameState)
        }

        var minimumCost = Int.max

        for possibleMove in possibleMoves {
            if possibleMove.cost > minimumCost {
                continue
            }

            let newGameState = executeMove(possibleMove, on: gameState)

            let subCosts = playAllNextPossibleMoves(with: newGameState, stateCostCache: &stateCostCache)

            if subCosts != Int.max {
                minimumCost = min(minimumCost, possibleMove.cost + subCosts)
            }
        }

        stateCostCache[gameState.cacheKey] = minimumCost

        return minimumCost
    }

    func solvePart1() -> Any {
        let initialGameState = GameState(hallway: .init(), rooms: input.rooms, totalCost: 0)

        // we store game state -> minimum cost when it is available
        var gameStateCostCache: [String: Int] = [:]

        return playAllNextPossibleMoves(with: initialGameState, stateCostCache: &gameStateCostCache)
    }

    func solvePart2() -> Any {
        var rooms = input.rooms

        rooms[0].cells.insert(.desert, at: 1)
        rooms[0].cells.insert(.desert, at: 2)
        rooms[1].cells.insert(.copper, at: 1)
        rooms[1].cells.insert(.bronze, at: 2)
        rooms[2].cells.insert(.bronze, at: 1)
        rooms[2].cells.insert(.amber, at: 2)
        rooms[3].cells.insert(.amber, at: 1)
        rooms[3].cells.insert(.copper, at: 2)

        let initialGameState = GameState(hallway: .init(), rooms: rooms, totalCost: 0)

        // we store game state -> minimum cost when it is available
        var gameStateCostCache: [String: Int] = [:]

        return playAllNextPossibleMoves(with: initialGameState, stateCostCache: &gameStateCostCache)
    }

    func parseInput(rawString: String) {
        input = .init(rooms: [
            .init(amphipod: .amber, cells: [.amber, .desert]),
            .init(amphipod: .bronze, cells: [.copper, .desert]),
            .init(amphipod: .copper, cells: [.bronze, .bronze]),
            .init(amphipod: .desert, cells: [.amber, .copper]),
        ])
//
//        input = .init(rooms: [
//            .init(amphipod: .amber, cells: [.amber, .desert, .desert, .desert]),
//            .init(amphipod: .bronze, cells: [.copper, .copper, .bronze, .desert]),
//            .init(amphipod: .copper, cells: [.bronze, .bronze, .amber, .bronze]),
//            .init(amphipod: .desert, cells: [.amber, .amber, .copper, .copper]),
//        ])
    }
}
