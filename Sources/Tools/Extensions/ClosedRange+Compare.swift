public extension ClosedRange {
	func contains(_ otherRange: ClosedRange) -> Bool {
		contains(otherRange.lowerBound) && contains(otherRange.upperBound)
	}
}
