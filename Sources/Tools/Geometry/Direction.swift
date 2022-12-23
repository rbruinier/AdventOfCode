public enum Direction: Int, Equatable {
    case north = 0
    case east = 1
    case south = 2
    case west = 3

    case northWest = 4
    case northEast = 5
    case southWest = 6
    case southEast = 7

    public static let allStraight: [Direction] = [
        .north,
        .east,
        .south,
        .west
    ]

    public static let allDiagonal: [Direction] = [
        .northWest,
        .northEast,
        .southEast,
        .southWest
    ]

    public static let all: [Direction] = [
        .north,
        .east,
        .south,
        .west,
        .northWest,
        .northEast,
        .southEast,
        .southWest
    ]

    public var left: Direction {
        switch self {
        case .north: return .west
        case .west: return .south
        case .south: return .east
        case .east: return .north
        case .northWest: return .southWest
        case .southWest: return .southEast
        case .southEast: return .northEast
        case .northEast: return .northWest
        }
    }

    public var right: Direction {
        switch self {
        case .north: return .east
        case .east: return .south
        case .south: return .west
        case .west: return .north
        case .northWest: return .northEast
        case .northEast: return .southEast
        case .southEast: return .southWest
        case .southWest: return .northWest
        }
    }

    public var opposite: Direction {
        switch self {
        case .north: return .south
        case .east: return .west
        case .south: return .north
        case .west: return .east
        case .northWest: return .southEast
        case .northEast: return .southWest
        case .southEast: return .northWest
        case .southWest: return .northEast
        }
    }

    public func turned(degrees: Point2D.Degrees) -> Direction {
        switch degrees {
        case .zero,
             .threeSixty: return self
        case .ninety: return right
        case .oneEighty: return opposite
        case .twoSeventy: return left
        }
    }
}
