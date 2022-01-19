import Foundation
import Tools

final class Day02Solver: DaySolver {
    let dayNumber: Int = 2

    private var input: Input!

    private struct Input {
        let movements: [(direction: Direction, count: Int)]
    }

    private enum Direction: String {
        case forward
        case down
        case up
    }

    func solvePart1() -> Any {
        var result: (x: Int, depth: Int) = (0, 0)

        result = input.movements.reduce(into: result) { result, movement in
            switch movement.direction {
            case .forward: result.x += movement.count
            case .down: result.depth += movement.count
            case .up: result.depth -= movement.count
            }
        }

        return result.x * result.depth
    }

    func solvePart2() -> Any {
        var result: (x: Int, depth: Int, aim: Int) = (0, 0, 0)

        result = input.movements.reduce(into: result) { result, movement in
            switch movement.direction {
            case .forward:
                result.x += movement.count
                result.depth += (movement.count * result.aim)
            case .down: result.aim += movement.count
            case .up: result.aim -= movement.count
            }
        }

        return result.x * result.depth
    }

    func parseInput(rawString: String) {
        let movements: [(direction: Direction, count: Int)] = rawString
            .components(separatedBy: .newlines)
            .filter { $0.isEmpty == false }
            .map {
                let components = $0.components(separatedBy: " ")

                return (direction: Direction(rawValue: components[0])!, count: Int(components[1])!)
            }

        input = .init(movements: movements)
    }
}
