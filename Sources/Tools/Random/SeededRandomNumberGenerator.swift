import Foundation

public final class SeededRandomNumberGenerator: RandomNumberGenerator {
	private let range: ClosedRange<Double> = Double(UInt64.min) ... Double(UInt64.max)

	public init(seed: Int) {
		srand48(seed)
	}

	public func next() -> UInt64 {
		UInt64(range.lowerBound + (range.upperBound - range.lowerBound) * drand48())
	}
}
