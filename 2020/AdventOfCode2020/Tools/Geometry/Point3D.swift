import Foundation

struct Point3D {
    var x: Int = 0
    var y: Int = 0
    var z: Int = 0
}

extension Point3D: CustomStringConvertible {
    var description: String {
        return "\(x), \(y), \(z)"
    }
}

extension Point3D: Hashable, Equatable { }
