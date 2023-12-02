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
		.west,
	]

	public static let allDiagonal: [Direction] = [
		.northWest,
		.northEast,
		.southEast,
		.southWest,
	]

	public static let all: [Direction] = [
		.north,
		.east,
		.south,
		.west,
		.northWest,
		.northEast,
		.southEast,
		.southWest,
	]

	public var left: Direction {
		switch self {
		case .north: .west
		case .west: .south
		case .south: .east
		case .east: .north
		case .northWest: .southWest
		case .southWest: .southEast
		case .southEast: .northEast
		case .northEast: .northWest
		}
	}

	public var right: Direction {
		switch self {
		case .north: .east
		case .east: .south
		case .south: .west
		case .west: .north
		case .northWest: .northEast
		case .northEast: .southEast
		case .southEast: .southWest
		case .southWest: .northWest
		}
	}

	public var opposite: Direction {
		switch self {
		case .north: .south
		case .east: .west
		case .south: .north
		case .west: .east
		case .northWest: .southEast
		case .northEast: .southWest
		case .southEast: .northWest
		case .southWest: .northEast
		}
	}

	public func turned(degrees: Point2D.Degrees) -> Direction {
		switch degrees {
		case .zero,
		     .threeSixty: self
		case .ninety: right
		case .oneEighty: opposite
		case .twoSeventy: left
		}
	}
}
