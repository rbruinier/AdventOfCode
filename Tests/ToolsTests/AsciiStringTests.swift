import Foundation
import Tools
import XCTest

final class AsciiStringTests: XCTestCase {
	private let asciiPizza: [UInt8] = [80, 105, 122, 122, 97]

	func testStringInitialization() {
		let sut = AsciiString(string: "Pizza")

		XCTAssertEqual(sut.count, 5)

		for i in 0 ..< 5 {
			XCTAssertEqual(sut[i], asciiPizza[i])
		}
	}

	func testEqualOperator() {
		let sut1 = AsciiString(string: "Pizza")
		let sut2 = AsciiString(string: "Pizza")

		XCTAssertEqual(sut1, sut2)

		let sut3 = AsciiString(string: "Not Pizza")

		XCTAssertNotEqual(sut1, sut3)
	}

	func testIteration() {
		let sut = AsciiString(string: "Pizza")

		for (index, character) in sut.enumerated() {
			XCTAssertEqual(character, asciiPizza[index])
		}
	}
}
