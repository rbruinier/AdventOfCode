import Foundation
import Tools
import XCTest

final class DijkstraTests: XCTestCase {
	func testShortestPathInWeightedGraph() {
		let graph = WeightedGraph(elementsCount: 4, edges: [
			.init(a: 0, b: 1, weight: 40), // A - B
			.init(a: 0, b: 2, weight: 30), // A - C
			.init(a: 0, b: 3, weight: 60), // A - C
			.init(a: 1, b: 2, weight: 10), // B - C
			.init(a: 2, b: 3, weight: 10), // C - D
		])

		// A -> C -> D
		let result = Dijkstra.shortestPathInGraph(graph, from: 0, to: 3)!

		XCTAssertEqual(result.pathIndices, [0, 2, 3])
		XCTAssertEqual(result.weight, 40)
	}

	func testShortestPathInUnweightedGraph() {
		let graph = UnweightedGraph(elementsCount: 4, edges: [
			.init(a: 0, b: 1), // A - B
			.init(a: 0, b: 2), // A - C
			.init(a: 0, b: 3), // A - C
			.init(a: 1, b: 2), // B - C
			.init(a: 2, b: 3), // C - D
		])

		// A -> C -> D
		let result = Dijkstra.shortestPathInGraph(graph, from: 0, to: 3)!

		XCTAssertEqual(result.pathIndices, [0, 3])
		XCTAssertEqual(result.steps, 1)
	}
}
