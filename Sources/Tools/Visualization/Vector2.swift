public struct Vector2 {
	public var x: Double
	public var y: Double

	public init(x: Double = 0, y: Double = 0) {
		self.x = x
		self.y = y
	}

	public static func + (lhs: Vector2, rhs: Vector2) -> Vector2 {
		.init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}

	public static func - (lhs: Vector2, rhs: Vector2) -> Vector2 {
		.init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
	}

	public static func * (lhs: Vector2, rhs: Vector2) -> Vector2 {
		.init(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
	}

	public static func += (lhs: inout Vector2, rhs: Vector2) {
		lhs.x += rhs.x
		lhs.y += rhs.y
	}

	public static func -= (lhs: inout Vector2, rhs: Vector2) {
		lhs.x -= rhs.x
		lhs.y -= rhs.y
	}

	public static func *= (lhs: inout Vector2, rhs: Vector2) {
		lhs.x *= rhs.x
		lhs.y *= rhs.y
	}
}
