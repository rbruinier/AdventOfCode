import Foundation
import Tools
import XCTest

final class PriorityQueueTests: XCTestCase {
	func testPushAndPopAscending() {
		let items: [Int] = [6, 5, 3, 1, 8, 7, 2, 4]

		var sut: PriorityQueue<Int> = PriorityQueue(isAscending: true, initialValues: items)

		XCTAssertEqual(sut.count, items.count)

		for item in items.sorted() {
			XCTAssertEqual(sut.pop(), item)
		}
	}

	func testPushAndPopDescending() {
		let items: [Int] = [6, 5, 3, 1, 8, 7, 2, 4]

		var sut: PriorityQueue<Int> = PriorityQueue(isAscending: false, initialValues: items)

		XCTAssertEqual(sut.count, items.count)

		for item in items.sorted().reversed() {
			XCTAssertEqual(sut.pop(), item)
		}
	}

	func testPushIdenticalValues() {
		let items: [Int] = [6, 5, 3, 6, 6, 7, 5, 4]

		var sut: PriorityQueue<Int> = PriorityQueue(isAscending: false, initialValues: items)

		XCTAssertEqual(sut.count, items.count)

		for item in items.sorted().reversed() {
			XCTAssertEqual(sut.pop(), item)
		}
	}

	func testPushNewElements() {
		let items: [Int] = [6, 5, 3, 1, 8, 7, 2, 4]

		var sut: PriorityQueue<Int> = PriorityQueue(initialValues: items)

		XCTAssertEqual(sut.count, items.count)

		for item in items.sorted().reversed()[0 ..< 4] {
			XCTAssertEqual(sut.pop(), item)
		}

		sut.push(8)
		sut.push(5)
		sut.push(7)
		sut.push(6)

		for item in items.sorted().reversed() {
			XCTAssertEqual(sut.pop(), item)
		}
	}

	func testPeakAndPopEmpty() {
		var sut: PriorityQueue<Int> = PriorityQueue()

		XCTAssertEqual(sut.peek(), nil)
		XCTAssertEqual(sut.pop(), nil)
	}
}
