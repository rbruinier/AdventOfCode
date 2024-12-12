import Foundation

public struct Matrix3 {
	public var xx: Double = 0
	public var xy: Double = 0
	public var xz: Double = 0
	public var yx: Double = 0
	public var yy: Double = 0
	public var yz: Double = 0
	public var zx: Double = 0
	public var zy: Double = 0
	public var zz: Double = 0

	public init() {
		xx = 1
		yy = 1
		zz = 1
	}

	public init(xx: Double, xy: Double, xz: Double, yx: Double, yy: Double, yz: Double, zx: Double, zy: Double, zz: Double) {
		self.xx = xx
		self.xy = xy
		self.xz = xz
		self.yx = yx
		self.yy = yy
		self.yz = yz
		self.zx = zx
		self.zy = zy
		self.zz = zz
	}

	public static func rotateX(radians: Double) -> Matrix3 {
		var result = Matrix3()

		result.yy = cos(radians)
		result.yz = -sin(radians)
		result.zy = sin(radians)
		result.zz = cos(radians)

		return result
	}

	public static func * (lhs: Matrix3, rhs: Matrix3) -> Matrix3 {
		.init(
			xx: (lhs.xx * rhs.xx) + (lhs.xy * rhs.yx) + (lhs.xz * rhs.zx),
			xy: (lhs.xx * rhs.xy) + (lhs.xy * rhs.yy) + (lhs.xz * rhs.zy),
			xz: (lhs.xx * rhs.xz) + (lhs.xy * rhs.yz) + (lhs.xz * rhs.zz),
			yx: (lhs.yx * rhs.xx) + (lhs.yy * rhs.yx) + (lhs.yz * rhs.zx),
			yy: (lhs.yx * rhs.xy) + (lhs.yy * rhs.yy) + (lhs.yz * rhs.zy),
			yz: (lhs.yx * rhs.xz) + (lhs.yy * rhs.yz) + (lhs.yz * rhs.zz),
			zx: (lhs.zx * rhs.xx) + (lhs.zy * rhs.yx) + (lhs.zz * rhs.zx),
			zy: (lhs.zx * rhs.xz) + (lhs.zy * rhs.yz) + (lhs.zz * rhs.zz),
			zz: (lhs.zx * rhs.xz) + (lhs.zy * rhs.yz) + (lhs.zz * rhs.zz)
		)
	}

	public static func * (lhs: Matrix3, rhs: Vector3) -> Vector3 {
		.init(
			x: (lhs.xx * rhs.x) + (lhs.xy * rhs.y) + (lhs.xz * rhs.z),
			y: (lhs.yx * rhs.x) + (lhs.yy * rhs.y) + (lhs.yz * rhs.z),
			z: (lhs.zx * rhs.x) + (lhs.zy * rhs.y) + (lhs.zz * rhs.z)
		)
	}

	public static func *= (lhs: inout Matrix3, rhs: Matrix3) {
		lhs = lhs * rhs
	}
}
