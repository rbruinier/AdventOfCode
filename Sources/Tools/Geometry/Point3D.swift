import Foundation

public struct Point3D {
	public var x: Int = 0
	public var y: Int = 0
	public var z: Int = 0

	public static let zero = Point3D(x: 0, y: 0, z: 0)

	public init() {}

	public init(x: Int, y: Int, z: Int) {
		self.x = x
		self.y = y
		self.z = z
	}

	public init(commaSeparatedString: String) {
		let components = commaSeparatedString.components(separatedBy: ",")

		x = Int(components[0])!
		y = Int(components[1])!
		z = Int(components[2])!
	}

	public func manhattanDistance(from rhs: Point3D) -> Int {
		let difference = rhs - self

		return abs(difference.x) + abs(difference.y) + abs(difference.z)
	}

	public func neighbors() -> [Point3D] {
		[
			.init(x: x - 1, y: y, z: z),
			.init(x: x + 1, y: y, z: z),
			.init(x: x, y: y - 1, z: z),
			.init(x: x, y: y + 1, z: z),
			.init(x: x, y: y, z: z - 1),
			.init(x: x, y: y, z: z + 1),
		]
	}

	public static func + (lhs: Point3D, rhs: Point3D) -> Point3D {
		.init(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
	}

	public static func - (lhs: Point3D, rhs: Point3D) -> Point3D {
		.init(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
	}

	public static func * (lhs: Point3D, rhs: Point3D) -> Point3D {
		.init(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z)
	}

	public static func += (lhs: inout Point3D, rhs: Point3D) {
		lhs.x += rhs.x
		lhs.y += rhs.y
		lhs.z += rhs.z
	}

	public static func -= (lhs: inout Point3D, rhs: Point3D) {
		lhs.x -= rhs.x
		lhs.y -= rhs.y
		lhs.z -= rhs.z
	}

	public static func *= (lhs: inout Point3D, rhs: Point3D) {
		lhs.x *= rhs.x
		lhs.y *= rhs.y
		lhs.z *= rhs.z
	}
}

// MARK: - CustomStringConvertible

extension Point3D: CustomStringConvertible {
	public var description: String {
		"\(x), \(y), \(z)"
	}
}

extension Point3D: Hashable, Equatable {}
