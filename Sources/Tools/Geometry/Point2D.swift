// Created by Robert Bruinier

import Foundation

public struct Point2D: Hashable, Equatable {
    public enum Degrees: Int {
        case zero = 0
        case ninety = 90
        case oneEighty = 180
        case twoSeventy = 270
        case threeSixty = 360

        public init?(rawValue: Int) {
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

    public var x: Int = 0
    public var y: Int = 0

    public init() {
    }

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    public func turned(degrees: Degrees) -> Point2D {
        switch degrees {
        case .zero, .threeSixty: return self
        case .ninety: return .init(x: y, y: -x)
        case .oneEighty: return .init(x: -x, y: -y)
        case .twoSeventy: return .init(x: -y, y: x)
        }
    }

    public static func + (lhs: Point2D, rhs: Point2D) -> Point2D {
        return .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func - (lhs: Point2D, rhs: Point2D) -> Point2D {
        return .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    public static func * (lhs: Point2D, rhs: Point2D) -> Point2D {
        return .init(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }

    public static func += (lhs: inout Point2D, rhs: Point2D) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }

    public static func -= (lhs: inout Point2D, rhs: Point2D) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }

    public static func *= (lhs: inout Point2D, rhs: Point2D) {
        lhs.x *= rhs.x
        lhs.y *= rhs.y
    }
}

extension Point2D: CustomStringConvertible {
    public var description: String {
        return "(\(x), \(y))"
    }
}
