/// Cube coordinates (https://www.redblobgames.com/grids/hexagons/#coordinates)
public struct HexPoint: Hashable {
	public var q = 0
	public var r = 0
	public var s = 0

	public static let zero = HexPoint()

	public init(q: Int = 0, r: Int = 0, s: Int = 0) {
		self.q = q
		self.r = r
		self.s = s
	}

	public static func + (lhs: HexPoint, rhs: HexPoint) -> HexPoint {
		.init(q: lhs.q + rhs.q, r: lhs.r + rhs.r, s: lhs.s + rhs.s)
	}

	public static func - (lhs: HexPoint, rhs: HexPoint) -> HexPoint {
		.init(q: lhs.q - rhs.q, r: lhs.r - rhs.r, s: lhs.s - rhs.s)
	}

	public func manhattanDistance(from rhs: HexPoint) -> Int {
		let difference = rhs - self

		return max(abs(difference.q), abs(difference.r), abs(difference.s))
	}

	public func moved(to direction: HexDirection, steps: Int = 1) -> HexPoint {
		switch direction {
		case .north: self + .init(q: 0, r: -steps, s: steps)
		case .northEast: self + .init(q: steps, r: -steps, s: 0)
		case .southEast: self + .init(q: steps, r: 0, s: -steps)
		case .south: self + .init(q: 0, r: steps, s: -steps)
		case .southWest: self + .init(q: -steps, r: steps, s: 0)
		case .northWest: self + .init(q: -steps, r: 0, s: steps)
		}
	}
}

public enum HexDirection: CustomStringConvertible {
	case north
	case northEast
	case southEast
	case south
	case southWest
	case northWest

	public init?(_ value: String) {
		switch value {
		case "n": self = .north
		case "s": self = .south
		case "ne": self = .northEast
		case "se": self = .southEast
		case "nw": self = .northWest
		case "sw": self = .southWest
		default: return nil
		}
	}

	public var description: String {
		switch self {
		case .north: "n"
		case .south: "s"
		case .northEast: "ne"
		case .southEast: "se"
		case .northWest: "nw"
		case .southWest: "sw"
		}
	}
}
