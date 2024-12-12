import Foundation
import Tools
import XCTest

final class MathTests: XCTestCase {
	func testDivisorSigma() {
		XCTAssertEqual(Math.divisorSigma(n: 12), 28)
		XCTAssertEqual(Math.divisorSigma(n: 1), 1)
		XCTAssertEqual(Math.divisorSigma(n: 2), 3)
		XCTAssertEqual(Math.divisorSigma(n: 3), 4)
		XCTAssertEqual(Math.divisorSigma(n: 4), 7)
		XCTAssertEqual(Math.divisorSigma(n: -1), 0)
	}

	func testGreatestCommonFactor() {
		XCTAssertEqual(Math.greatestCommonFactor(8, 12), 4)
		XCTAssertEqual(Math.greatestCommonFactor(18, 24), 6)
		XCTAssertEqual(Math.greatestCommonFactor(10, 50), 10)
		XCTAssertEqual(Math.greatestCommonFactor(9, 50), 1)
	}

	func testLeastCommonMultiplier() {
		XCTAssertEqual(Math.leastCommonMultiple(for: 4, and: 6), 12)
		XCTAssertEqual(Math.leastCommonMultiple(for: 5, and: 8), 40)
		XCTAssertEqual(Math.leastCommonMultiple(for: 9, and: 51), 153)

		XCTAssertEqual(Math.leastCommonMultiple(for: [4, 6]), 12)
		XCTAssertEqual(Math.leastCommonMultiple(for: [4, 6, 5, 8]), 120)
	}

	func testIsPrime() {
		XCTAssertFalse(1.isPrime)
		XCTAssertTrue(2.isPrime)
		XCTAssertTrue(3.isPrime)
		XCTAssertFalse(4.isPrime)
		XCTAssertTrue(5.isPrime)
		XCTAssertFalse(6.isPrime)
		XCTAssertTrue(7.isPrime)
		XCTAssertFalse(8.isPrime)
		XCTAssertFalse(9.isPrime)
	}
}
