public enum Direction: Int, Equatable, CaseIterable {
    case north = 0
    case east = 1
    case south = 2
    case west = 3

    public var left: Direction {
        switch self {
        case .north: return .west
        case .west: return .south
        case .south: return .east
        case .east: return .north
        }
    }

    public var right: Direction {
        switch self {
        case .north: return .east
        case .east: return .south
        case .south: return .west
        case .west: return .north
        }
    }

    public var opposite: Direction {
        switch self {
        case .north: return .south
        case .east: return .west
        case .south: return .north
        case .west: return .east
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
