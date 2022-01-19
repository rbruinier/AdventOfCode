import Foundation
import Tools

final class Day12Solver: DaySolver {
    let dayNumber: Int = 12

    private var input: Input!

    private struct Input {
        let actions: [Action]
    }

    private enum Action {
        case moveNorth(value: Int)
        case moveEast(value: Int)
        case moveSouth(value: Int)
        case moveWest(value: Int)
        case turnLeft(degrees: Int)
        case turnRight(degrees: Int)
        case moveForward(value: Int)
    }

    private enum Orientation: Int {
        case north = 0
        case east = 90
        case south = 180
        case west = 270

        func turned(with degrees: Int) -> Orientation {
            let orientationDegrees = (self.rawValue + degrees) % 360

            return Orientation(rawValue: orientationDegrees)!
        }
    }

    func solvePart1() -> Any {
        var orientation: Orientation = .east

        var ship = Point2D()

        for action in input.actions {
            switch action {
            case .moveNorth(let value): ship.y += value
            case .moveEast(let value): ship.x += value
            case .moveSouth(let value): ship.y -= value
            case .moveWest(let value): ship.x -= value
            case .turnLeft(let degrees): orientation = orientation.turned(with: 360 - degrees)
            case .turnRight(let degrees): orientation = orientation.turned(with: degrees)
            case .moveForward(let value):
                switch orientation {
                case .north: ship.y += value
                case .east: ship.x += value
                case .south: ship.y -= value
                case .west: ship.x -= value
                }
            }
        }

        return abs(ship.x) + abs(ship.y)
    }

    func solvePart2() -> Any {
        var ship = Point2D()
        var waypoint = Point2D(x: 10, y: 1)

        for action in input.actions {
            switch action {
            case .moveNorth(let value): waypoint.y += value
            case .moveEast(let value): waypoint.x += value
            case .moveSouth(let value): waypoint.y -= value
            case .moveWest(let value): waypoint.x -= value
            case .turnLeft(let degrees):
                waypoint = waypoint.turned(degrees: .init(rawValue: -degrees)!)
            case .turnRight(let degrees):
                waypoint = waypoint.turned(degrees: .init(rawValue: degrees)!)
            case .moveForward(let value):
                ship.x += waypoint.x * value
                ship.y += waypoint.y * value
            }
        }

        return abs(ship.x) + abs(ship.y)
    }

    func parseInput(rawString: String) {
        let actions: [Action] = rawString.components(separatedBy: .newlines).filter { $0.isNotEmpty }.compactMap { line in
            let value = Int(line[line.index(line.startIndex, offsetBy: 1) ..< line.endIndex])!

            switch line.first! {
            case "N": return .moveNorth(value: value)
            case "S": return .moveSouth(value: value)
            case "W": return .moveWest(value: value)
            case "E": return .moveEast(value: value)
            case "L": return .turnLeft(degrees: value)
            case "R": return .turnRight(degrees: value)
            case "F": return .moveForward(value: value)
            default: fatalError()
            }
        }

        input = .init(actions: actions)
    }
}
