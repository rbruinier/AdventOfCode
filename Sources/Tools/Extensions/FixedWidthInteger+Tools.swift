import Foundation

extension FixedWidthInteger {
    @inline(__always)
    public var isEven: Bool {
        self & 1 == 0
    }

    @inline(__always)
    public var isOdd: Bool {
        self & 1 == 1
    }
}
