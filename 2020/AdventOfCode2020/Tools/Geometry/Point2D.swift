// Created by Robert Bruinier

import Foundation

struct Point2D: Hashable, Equatable {
    enum Degrees: Int {
        case zero = 0
        case ninety = 90
        case oneEighty = 180
        case twoSeventy = 270
        case threeSixty = 360

        init?(rawValue: Int) {
            var degrees = rawValue % 360

            if degrees < 0 {
                degrees = 360 + degrees
            }

            switch degrees {
            case 0, 360: self = .zero
            case 90: self = .ninety
            case 180: self = .oneEighty
            case 270: self = .twoSeventy
            default: return nil
            }
        }
    }

    var x: Int = 0
    var y: Int = 0

    func turned(degrees: Degrees) -> Point2D {
        switch degrees {
        case .zero, .threeSixty: return self
        case .ninety: return .init(x: y, y: -x)
        case .oneEighty: return .init(x: -x, y: -y)
        case .twoSeventy: return .init(x: -y, y: x)
        }
    }

    static func + (lhs: Point2D, rhs: Point2D) -> Point2D {
        return .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

extension Point2D: CustomStringConvertible {
    var description: String {
        return "\(x), \(y)"
    }
}
