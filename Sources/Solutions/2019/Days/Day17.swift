import Foundation
import Tools

final class Day17Solver: DaySolver {
    let dayNumber: Int = 17

    private var input: Input!

    private struct Input {
        let program: [Int]
    }

    private enum Tile: Equatable {
        case scaffold
        case empty
        case robot(direction: Direction)
    }

    private var tiles: [Point2D: Tile] = [:]

    private func printGame(with tiles: [Point2D: Tile]) {
        let minX = tiles.keys.map { $0.x }.min()!
        let minY = tiles.keys.map { $0.y }.min()!

        let maxX = tiles.keys.map { $0.x }.max()!
        let maxY = tiles.keys.map { $0.y }.max()!

        for y in minY ... maxY {
            var line = ""

            for x in minX ... maxX {
                switch tiles[.init(x: x, y: y)] {
                case nil: line += "?"
                case .scaffold: line += "#"
                case .empty: line += "."
                case .robot(let direction):
                    switch direction {
                    case .north: line += "^"
                    case .west: line += "<"
                    case .east: line += ">"
                    case .south: line += "v"
                    }
                }
            }
        }
    }

    func solvePart1() -> Any {
        let intcode = IntcodeProcessor(program: input.program)

        var position = Point2D()

        while true {
            guard let output = intcode.continueProgramTillOutput(input: []) else {
                break
            }

            switch output {
            case 35:
                tiles[position] = .scaffold

                position.x += 1
            case 46:
                tiles[position] = .empty

                position.x += 1
            case 10:
                position.x = 0
                position.y += 1
            case 60: // <
                tiles[position] = .robot(direction: .west)

                position.x += 1
            case 62: // >
                tiles[position] = .robot(direction: .east)

                position.x += 1
            case 94: // ^
                tiles[position] = .robot(direction: .north)

                position.x += 1
            case 118: // v
                tiles[position] = .robot(direction: .south)

                position.x += 1
            default: fatalError()
            }
        }

//        printGame(with: tiles)

        let minX = tiles.keys.map { $0.x }.min()!
        let minY = tiles.keys.map { $0.y }.min()!

        let maxX = tiles.keys.map { $0.x }.max()!
        let maxY = tiles.keys.map { $0.y }.max()!

        var sum = 0
        for y in minY ..< maxY {
            for x in minX ..< maxX {
                let point = Point2D(x: x, y: y)

                let isIntersection = tiles[point] == .scaffold
                    && tiles[point + Point2D(x: 0, y: -1)] == .scaffold
                    && tiles[point + Point2D(x: 0, y: 1)] == .scaffold
                    && tiles[point + Point2D(x: 1, y: 0)] == .scaffold
                    && tiles[point + Point2D(x: -1, y: 0)] == .scaffold

                if isIntersection {
                    sum += point.x * point.y
                }
            }
        }

        return sum
    }

    func solvePart2() -> Any {
        var position: Point2D!
        var direction: Direction = .north

        for (point, tile) in tiles {
            if case .robot = tile {
                position = point

                break
            }
        }

        var instructions: [String] = []
        var counter = 0

        while true {
            var newPosition = position.moved(to: direction)

            if tiles[newPosition] == .scaffold {
                position = newPosition

                counter += 1
            } else {
                newPosition = position.moved(to: direction.right)

                if tiles[newPosition] == .scaffold {
                    direction = direction.right

                    if counter > 1 {
                        instructions += [String(counter)]

                        counter = 0
                    }

                    instructions += ["R"]

                    continue
                }

                newPosition = position.moved(to: direction.left)

                if tiles[newPosition] == .scaffold {
                    direction = direction.left

                    if counter > 1 {
                        instructions += [String(counter)]

                        counter = 0
                    }

                    instructions += ["L"]

                    continue
                }

                if counter > 0 {
                    instructions += [String(counter)]

                    counter = 0
                }

                break
            }
        }

//        print(instructions)

        /*
         Solved resulting subdivision of program manually. Todo: find automated way to find repeating matching patterns

         Program: "R", "6", "L", "10", "R", "8", "R", "8", "R", "12", "L", "8", "L", "8", "R", "6", "L", "10", "R", "8", "R", "8", "R", "12", "L", "8", "L", "8", "L", "10", "R", "6", "R", "6", "L", "8", "R", "6", "L", "10", "R", "8", "R", "8", "R", "12", "L", "8", "L", "8", "L", "10", "R", "6", "R", "6", "L", "8", "R", "6", "L", "10", "R", "8", "L", "10", "R", "6", "R", "6", "L", "8"

         A: "R", "6", "L", "10", "R", "8",
         B: "R", "8", "R", "12", "L", "8", "L", "8",
         A: "R", "6", "L", "10", "R", "8",
         B: "R", "8", "R", "12", "L", "8", "L", "8",
         C: "L", "10", "R", "6", "R", "6", "L", "8",
         A: "R", "6", "L", "10", "R", "8",
         B: "R", "8", "R", "12", "L", "8", "L", "8",
         C: "L", "10", "R", "6", "R", "6", "L", "8",
         A: "R", "6", "L", "10", "R", "8",
         B: "L", "10", "R", "6", "R", "6", "L", "8"

         -> A, B, A, B, C, A, B, C, A, C
         */

        var program = input.program

        program[0] = 2 // interactive robot

        let intcode = IntcodeProcessor(program: program)

        let buffer: String = """
            A,B,A,B,C,A,B,C,A,C
            R,6,L,10,R,8
            R,8,R,12,L,8,L,8
            L,10,R,6,R,6,L,8

            n

            """

        var asciiBuffer = buffer.map { Int($0.asciiValue!) }

        while true {
            guard let output = intcode.continueProgramTillOutput(input: &asciiBuffer) else {
                break
            }

            if output > 127 {
                return output
            }
        }

        return 0
    }

    func parseInput(rawString: String) {
        input = .init(program: rawString.parseCommaSeparatedInts())
    }
}
