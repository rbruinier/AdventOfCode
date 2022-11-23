import Foundation
import Tools
import XCTest

final class BFSTests: XCTestCase {
	func testShortestDistance() {
		let items: [String] = ["A", "B", "C", "D"]

		let graph = WeightedGraph(elements: items, edges: [
			.init(a: 0, b: 1, weight: 60), // A - B = 60
			.init(a: 0, b: 2, weight: 60), // A - C = 60
			.init(a: 0, b: 3, weight: 10), // A - D = 10
			.init(a: 1, b: 2, weight: 10), // B - C = 60
			.init(a: 1, b: 3, weight: 10), // B - D = 10
			.init(a: 2, b: 3, weight: 60), // C - D = 10
		])
		
		// A(0) (10) -> D(3) (10) -> B(1) -> C(2)

		let sut = BFS(graph: graph)

		let result = sut.visitAllElements()!

		XCTAssertEqual(result.pathIndices, [0, 3, 1, 2])
		XCTAssertEqual(result.pathWeight, 30)
	}
	
	func testIdenticalWeightsShortestDistance() {
		let items: [String] = ["A", "B", "C", "D"]
		
		let graph = WeightedGraph(elements: items, edges: [
			.init(a: 0, b: 1, weight: 10), // A - B = 10
			.init(a: 0, b: 2, weight: 10), // A - C = 10
			.init(a: 0, b: 3, weight: 10), // A - D = 10
			.init(a: 1, b: 2, weight: 10), // B - C = 10
			.init(a: 1, b: 3, weight: 10), // B - D = 20
			.init(a: 2, b: 3, weight: 10), // C - D = 30
		])
		
		let sut = BFS(graph: graph)
		
		let result = sut.visitAllElements()!
		
		XCTAssertEqual(result.pathIndices, [0, 1, 2, 3])
		XCTAssertEqual(result.pathWeight, 30)
	}
}
