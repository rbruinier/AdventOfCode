import Foundation

public struct Point3D {
    public var x: Int = 0
    public var y: Int = 0
    public var z: Int = 0

    public init() {
    }

    public init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }

    public static func + (lhs: Point3D, rhs: Point3D) -> Point3D {
        return .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }

    public static func - (lhs: Point3D, rhs: Point3D) -> Point3D {
        return .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }

    public static func * (lhs: Point3D, rhs: Point3D) -> Point3D {
        return .init(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z)
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

extension Point3D: CustomStringConvertible {
    public var description: String {
        return "\(x), \(y), \(z)"
    }
}

extension Point3D: Hashable, Equatable { }
