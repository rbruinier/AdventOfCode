public struct Size: Equatable {
    public let width: Int
    public let height: Int

    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    public static var zero: Size {
        .init(width: 0, height: 0)
    }
}
