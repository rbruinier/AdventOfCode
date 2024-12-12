import Foundation

public extension FixedWidthInteger {
	@inline(__always)
	var isEven: Bool {
		self & 1 == 0
	}

	@inline(__always)
	var isOdd: Bool {
		self & 1 == 1
	}
}
