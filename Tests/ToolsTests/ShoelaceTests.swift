import Foundation
import Tools
import XCTest

final class ShoelaceTests: XCTestCase {
	func testAreaWithoutBorder() {
		let points: [Point2D] = [
			.init(x: 2, y: 7),
			.init(x: 10, y: 1),
			.init(x: 8, y: 6),
			.init(x: 11, y: 7),
			.init(x: 7, y: 10),
		]

		XCTAssertEqual(Shoelace.calculateArea(of: points, includeBorder: false), 32)
	}

	func testAreaWithBorder() {
		let points: [Point2D] = [
			.init(x: 2, y: 7),
			.init(x: 10, y: 1),
			.init(x: 8, y: 6),
			.init(x: 11, y: 7),
			.init(x: 7, y: 10),
		]

		XCTAssertEqual(Shoelace.calculateArea(of: points, includeBorder: true), 53)
	}
}
