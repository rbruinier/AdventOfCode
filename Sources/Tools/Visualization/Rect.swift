public struct Rect: Equatable {
    public let origin: Point2D
    public let size: Size

    public var topLeft: Point2D {
        origin
    }

    public var bottomRight: Point2D {
        .init(x: origin.x + size.width, y: origin.y + size.height)
    }

    public static var zero: Rect {
        .init(origin: .zero, size: .zero)
    }

    public init(origin: Point2D, size: Size) {
        self.origin = origin
        self.size = size
    }

    public func clippedWith(rect: Rect) -> Rect {
        let topLeftX = max(origin.x, rect.origin.x)
        let topLeftY = max(origin.y, rect.origin.y)

        let bottomRightX = min(bottomRight.x, rect.bottomRight.x)
        let bottomRightY = min(bottomRight.y, rect.bottomRight.y)

        let width = bottomRightX - topLeftX
        let height = bottomRightY - topLeftY

        if width <= 0 || height <= 0 {
            return .zero
        }

        return .init(origin: .init(x: topLeftX, y: topLeftY), size: .init(width: width, height: height))
    }

    public func contains(point: Point2D) -> Bool {
        (topLeft.x ..< bottomRight.x).contains(point.x) && (topLeft.y ..< bottomRight.y).contains(point.y)
    }

    public func intersects(_ rhs: Rect) -> Bool {
        (topLeft.x <= rhs.bottomRight.x)
            && (rhs.topLeft.x <= bottomRight.x)
            && (topLeft.y <= rhs.bottomRight.y)
            && (rhs.topLeft.y <= bottomRight.y)
    }
}
