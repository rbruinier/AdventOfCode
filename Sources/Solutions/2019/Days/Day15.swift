import Foundation
import Tools

final class Day15Solver: DaySolver {
    let dayNumber: Int = 15

    private var input: Input!

    private struct Input {
        let program: [Int]
    }

    private enum Tile: Int {
        case wall = 0
        case empty = 1
        case oxygenSystem = 2
    }

    // we can cache the results from part 1 for part 2
    private var tiles: [Point2D: Tile] = [:]
    private var oxygenSystemPoint: Point2D!

    private func printGame(with tiles: [Point2D: Tile]) {
        let minX = tiles.keys.map { $0.x }.min()!
        let minY = tiles.keys.map { $0.y }.min()!

        let maxX = tiles.keys.map { $0.x }.max()!
        let maxY = tiles.keys.map { $0.y }.max()!

        for y in minY ... maxY {
            var line = ""

            for x in minX ... maxX {
                if y == 0 && x == 0 {
                    line += "S"

                    continue
                }

                switch tiles[.init(x: x, y: y)] {
                case nil: line += "?"
                case .wall: line += "+"
                case .empty: line += "."
                case .oxygenSystem: line += "#"
                }
            }

            print(line)
        }
    }

    func solvePart1() -> Any {
        let intcode = IntcodeProcessor(program: input.program)

        var position = Point2D()
        var direction: Direction = .north

        searchLoop: while true {
            var newPosition = position

            switch direction {
            case .north: newPosition += .init(x: 0, y: -1)
            case .east: newPosition += .init(x: 1, y: 0)
            case .south: newPosition += .init(x: 0, y: 1)
            case .west: newPosition += .init(x: -1, y: 0)
            }

            let output = intcode.continueProgramTillOutput(input: [direction.mazeCode])!

            let tile = Tile(rawValue: output)!

            // simple wall on the right algorithm to find the end point
            switch tile {
            case .empty:
                position = newPosition
                direction = direction.left

                if position == Point2D(x: 0, y: 0) {
                    break searchLoop
                }

                tiles[position] = tile
            case .wall:
                direction = direction.right

                tiles[newPosition] = tile
            case .oxygenSystem:
                position = newPosition

                tiles[newPosition] = tile

                oxygenSystemPoint = newPosition
            }
        }

        // breadth–first search for shortest path
        var cellQueue: [(point: Point2D, distance: Int)] = []

        cellQueue.append((point: Point2D(x: 0, y: 0), distance: 0))
        var visitedCells: [Point2D] = [Point2D(x: 0, y: 0)]

        while let cell = cellQueue.first {
            cellQueue.removeFirst()

            if cell.point == oxygenSystemPoint {
                return cell.distance
            }

            let neighborPoints = [
                cell.point + Point2D(x: 0, y: -1),
                cell.point + Point2D(x: 1, y: 0),
                cell.point + Point2D(x: 0, y: 1),
                cell.point + Point2D(x: -1, y: 0)
            ]

            for neighborPoint in neighborPoints {
                if visitedCells.contains(neighborPoint) == false {
                    switch tiles[neighborPoint] {
                    case nil, .wall: break
                    case .empty, .oxygenSystem:
                        visitedCells.append(cell.point)
                        cellQueue.append((point: neighborPoint, distance: cell.distance + 1))
                    }
                }
            }
        }

        return 0
    }

    func solvePart2() -> Any {
        // flood fill
        var cellQueue: [(point: Point2D, distance: Int)] = []

        cellQueue.append((point: oxygenSystemPoint, distance: 0))
        var visitedCells: [Point2D] = [oxygenSystemPoint]

        var maxDistance = Int.min

        while let cell = cellQueue.first {
            cellQueue.removeFirst()

            maxDistance = max(maxDistance, cell.distance)

            let neighborPoints = [
                cell.point + Point2D(x: 0, y: -1),
                cell.point + Point2D(x: 1, y: 0),
                cell.point + Point2D(x: 0, y: 1),
                cell.point + Point2D(x: -1, y: 0)
            ]

            for neighborPoint in neighborPoints {
                if visitedCells.contains(neighborPoint) == false {
                    switch tiles[neighborPoint] {
                    case nil, .wall: break
                    case .empty, .oxygenSystem:
                        visitedCells.append(cell.point)
                        cellQueue.append((point: neighborPoint, distance: cell.distance + 1))
                    }
                }
            }
        }

        return maxDistance
    }

    func parseInput(rawString: String) {
        input = .init(program: rawString.parseCommaSeparatedInts())
    }
}
