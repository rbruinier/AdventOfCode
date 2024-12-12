import Foundation

public struct Matrix4 {
	public var xx: Double = 0
	public var xy: Double = 0
	public var xz: Double = 0
	public var xw: Double = 0
	public var yx: Double = 0
	public var yy: Double = 0
	public var yz: Double = 0
	public var yw: Double = 0
	public var zx: Double = 0
	public var zy: Double = 0
	public var zz: Double = 0
	public var zw: Double = 0
	public var wx: Double = 0
	public var wy: Double = 0
	public var wz: Double = 0
	public var ww: Double = 0

	public init() {
		xx = 1
		yy = 1
		zz = 1
		ww = 1
	}

	public init(
		xx: Double, xy: Double, xz: Double, xw: Double,
		yx: Double, yy: Double, yz: Double, yw: Double,
		zx: Double, zy: Double, zz: Double, zw: Double,
		wx: Double, wy: Double, wz: Double, ww: Double
	) {
		self.xx = xx
		self.xy = xy
		self.xz = xz
		self.xw = xw
		self.yx = yx
		self.yy = yy
		self.yz = yz
		self.yw = yw
		self.zx = zx
		self.zy = zy
		self.zz = zz
		self.zw = zw
		self.wx = wx
		self.wy = wy
		self.wz = wz
		self.ww = ww
	}

	public static func rotateX(radians: Double) -> Matrix4 {
		var result = Matrix4()

		result.yy = cos(radians)
		result.yz = -sin(radians)
		result.zy = sin(radians)
		result.zz = cos(radians)

		return result
	}

	public static func * (lhs: Matrix4, rhs: Matrix4) -> Matrix4 {
		.init(
			xx: (lhs.xx * rhs.xx) + (lhs.xy * rhs.yx) + (lhs.xz * rhs.zx) + (lhs.xw * rhs.wx),
			xy: (lhs.xx * rhs.xy) + (lhs.xy * rhs.yy) + (lhs.xz * rhs.zy) + (lhs.xw * rhs.wy),
			xz: (lhs.xx * rhs.xz) + (lhs.xy * rhs.yz) + (lhs.xz * rhs.zz) + (lhs.xw * rhs.wz),
			xw: (lhs.xx * rhs.xw) + (lhs.xy * rhs.yw) + (lhs.xz * rhs.zw) + (lhs.xw * rhs.ww),

			yx: (lhs.yx * rhs.xx) + (lhs.yy * rhs.yx) + (lhs.yz * rhs.zx) + (lhs.yw * rhs.wx),
			yy: (lhs.yx * rhs.xy) + (lhs.yy * rhs.yy) + (lhs.yz * rhs.zy) + (lhs.yw * rhs.wy),
			yz: (lhs.yx * rhs.xz) + (lhs.yy * rhs.yz) + (lhs.yz * rhs.zz) + (lhs.yw * rhs.wz),
			yw: (lhs.yx * rhs.xw) + (lhs.yy * rhs.yw) + (lhs.yz * rhs.zw) + (lhs.yw * rhs.ww),

			zx: (lhs.zx * rhs.xx) + (lhs.zy * rhs.yx) + (lhs.zz * rhs.zx) + (lhs.zw * rhs.wx),
			zy: (lhs.zx * rhs.xy) + (lhs.zy * rhs.yz) + (lhs.zz * rhs.zz) + (lhs.zw * rhs.wy),
			zz: (lhs.zx * rhs.xz) + (lhs.zy * rhs.yz) + (lhs.zz * rhs.zz) + (lhs.zw * rhs.wz),
			zw: (lhs.zx * rhs.xw) + (lhs.zy * rhs.yz) + (lhs.zz * rhs.zz) + (lhs.zw * rhs.wz),

			wx: (lhs.wx * rhs.xx) + (lhs.wy * rhs.yx) + (lhs.wz * rhs.zx) + (lhs.ww * rhs.wx),
			wy: (lhs.wx * rhs.xy) + (lhs.wy * rhs.yy) + (lhs.wz * rhs.zy) + (lhs.ww * rhs.wy),
			wz: (lhs.wx * rhs.xz) + (lhs.wy * rhs.yz) + (lhs.wz * rhs.zz) + (lhs.ww * rhs.wz),
			ww: (lhs.wx * rhs.xw) + (lhs.wy * rhs.yw) + (lhs.wz * rhs.zw) + (lhs.ww * rhs.wz)
		)
	}

	public static func * (lhs: Matrix4, rhs: Vector3) -> Vector3 {
		.init(
			x: (lhs.xx * rhs.x) + (lhs.xy * rhs.y) + (lhs.xz * rhs.z) + lhs.xw,
			y: (lhs.yx * rhs.x) + (lhs.yy * rhs.y) + (lhs.yz * rhs.z) + lhs.yw,
			z: (lhs.zx * rhs.x) + (lhs.zy * rhs.y) + (lhs.zz * rhs.z) + lhs.yz
		)
	}

	public static func *= (lhs: inout Matrix4, rhs: Matrix4) {
		lhs = lhs * rhs
	}
}
