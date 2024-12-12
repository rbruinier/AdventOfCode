public struct Vector3 {
	public var x: Double
	public var y: Double
	public var z: Double

	public init(x: Double = 0, y: Double = 0, z: Double = 0) {
		self.x = x
		self.y = y
		self.z = z
	}

	public static func + (lhs: Vector3, rhs: Vector3) -> Vector3 {
		.init(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
	}

	public static func - (lhs: Vector3, rhs: Vector3) -> Vector3 {
		.init(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
	}

	public static func * (lhs: Vector3, rhs: Vector3) -> Vector3 {
		.init(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z)
	}

	public static func += (lhs: inout Vector3, rhs: Vector3) {
		lhs.x += rhs.x
		lhs.y += rhs.y
		lhs.z += rhs.z
	}

	public static func -= (lhs: inout Vector3, rhs: Vector3) {
		lhs.x -= rhs.x
		lhs.y -= rhs.y
		lhs.z -= rhs.z
	}

	public static func *= (lhs: inout Vector3, rhs: Vector3) {
		lhs.x *= rhs.x
		lhs.y *= rhs.y
		lhs.z *= rhs.z
	}
}
