import Foundation
import Tools

final class Day03Solver: DaySolver {
    let dayNumber: Int = 3

    private var input: Input!

    private struct Input {
        let directions: [Direction]
    }

    func solvePart1() -> Any {
        var point = Point2D()

        var points: Set<Point2D> = Set([point])

        for direction in input.directions {
            point = point.moved(to: direction)

            points.insert(point)
        }

        return points.count
    }

    func solvePart2() -> Any {
        var robot = Point2D()
        var santa = Point2D()

        var points: Set<Point2D> = Set([robot])

        for (index, direction) in input.directions.enumerated() {
            if index.isEven {
                santa = santa.moved(to: direction)

                points.insert(santa)
            } else {
                robot = robot.moved(to: direction)

                points.insert(robot)
            }
        }

        return points.count
    }

    func parseInput(rawString: String) {
        let directions: [Direction] = rawString.allLines().first!.map {
            switch $0 {
            case ">": return .east
            case "<": return .west
            case "v": return .south
            case "^": return .north
            default: fatalError()
            }
        }

        input = .init(directions: directions)
    }
}
