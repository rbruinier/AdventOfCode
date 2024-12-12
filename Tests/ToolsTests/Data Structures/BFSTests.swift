import Foundation
import Tools
import XCTest

final class BFSTests: XCTestCase {
	func testShortestPathInUnweightedGraph() {
		let items: [String] = ["A", "B", "C", "D"]

		let graph = UnweightedGraph(elementsCount: items.count, edges: [
			.init(a: 0, b: 1),
			.init(a: 0, b: 2),
			.init(a: 1, b: 2),
			.init(a: 1, b: 3),
			.init(a: 3, b: 1),
		])

		// A -> B -> D
		let result = BFS.shortestPathInGraph(graph, from: 0, to: 3)!

		XCTAssertEqual(result.pathIndices, [0, 1, 3])
		XCTAssertEqual(result.steps, 2)
	}

	func testShortestPathInUnweightedDirectionalGraph() {
		let items: [String] = ["A", "B", "C", "D"]

		let graph = UnweightedGraph(elementsCount: items.count, edges: [
			.init(a: 0, b: 1),
			.init(a: 0, b: 2),
			.init(a: 3, b: 1, isDirectional: true),
			.init(a: 1, b: 2, isDirectional: true),
			.init(a: 2, b: 3),
		])

		// A -> C -> D
		let result = BFS.shortestPathInGraph(graph, from: 0, to: 3)!

		XCTAssertEqual(result.pathIndices, [0, 2, 3])
		XCTAssertEqual(result.steps, 2)
	}

	func testShortestPathInWeightedGraph() {
		let items: [String] = ["A", "B", "C", "D"]

		let graph = WeightedGraph(elementsCount: items.count, edges: [
			.init(a: 0, b: 1, weight: 30), // A - B
			.init(a: 0, b: 2, weight: 60), // A - C
			.init(a: 1, b: 2, weight: 10), // B - C
			.init(a: 2, b: 3, weight: 10), // C - D
		])

		// A -> B -> D
		let result = BFS.shortestPathInGraph(graph, from: 0, to: 3)!

		XCTAssertEqual(result.pathIndices, [0, 1, 2, 3])
		XCTAssertEqual(result.weight, 50)
	}

	func testShortestPathInWeightedDirectionalGraph() {
		let items: [String] = ["A", "B", "C", "D"]

		let graph = WeightedGraph(elementsCount: items.count, edges: [
			.init(a: 1, b: 0, weight: 30, isDirectional: true), // A - B = 30
			.init(a: 0, b: 2, weight: 50), // A - C = 50
			.init(a: 1, b: 2, weight: 10), // B - C = 10
			.init(a: 2, b: 3, weight: 10), // C - D = 10
		])

		// A -> B -> D
		let result = BFS.shortestPathInGraph(graph, from: 0, to: 3)!

		XCTAssertEqual(result.pathIndices, [0, 2, 3])
		XCTAssertEqual(result.weight, 60)
	}

	func testShortestDistanceInWeightedGraphVisitingAllElements() {
		let items: [String] = ["A", "B", "C", "D"]

		let graph = WeightedGraph(elementsCount: items.count, edges: [
			.init(a: 0, b: 1, weight: 60), // A - B = 60
			.init(a: 0, b: 2, weight: 60), // A - C = 60
			.init(a: 0, b: 3, weight: 10), // A - D = 10
			.init(a: 1, b: 2, weight: 10), // B - C = 60
			.init(a: 1, b: 3, weight: 10), // B - D = 10
			.init(a: 2, b: 3, weight: 60), // C - D = 10
		])

		// A(0) (10) -> D(3) (10) -> B(1) -> C(2)

		let result = BFS.visitAllElementsInGraph(graph)!

		XCTAssertEqual(result.pathIndices, [0, 3, 1, 2])
		XCTAssertEqual(result.pathWeight, 30)
	}

	func testIdenticalWeightsShortestDistanceInWeightedGraphVisitingAllElements() {
		let items: [String] = ["A", "B", "C", "D"]

		let graph = WeightedGraph(elementsCount: items.count, edges: [
			.init(a: 0, b: 1, weight: 10), // A - B = 10
			.init(a: 0, b: 2, weight: 10), // A - C = 10
			.init(a: 0, b: 3, weight: 10), // A - D = 10
			.init(a: 1, b: 2, weight: 10), // B - C = 10
			.init(a: 1, b: 3, weight: 10), // B - D = 20
			.init(a: 2, b: 3, weight: 10), // C - D = 30
		])

		let result = BFS.visitAllElementsInGraph(graph)!

		XCTAssertEqual(result.pathIndices, [0, 1, 2, 3])
		XCTAssertEqual(result.pathWeight, 30)
	}

	func testShortestPathInGrid() {
		struct TestGrid: BFSGrid {
			// X/Y: 01234
			//
			//    0 10011
			//    1 10001
			//    2 11111

			let points: Set<Point2D> = [
				.init(x: 0, y: 0),
				.init(x: 3, y: 0),
				.init(x: 4, y: 0),
				.init(x: 0, y: 1),
				.init(x: 4, y: 1),
				.init(x: 0, y: 2),
				.init(x: 1, y: 2),
				.init(x: 2, y: 2),
				.init(x: 3, y: 2),
				.init(x: 4, y: 2),
			]

			func reachableNeighborsAt(position: Point2D) -> [Point2D] {
				position.neighbors().filter { points.contains($0) }
			}
		}

		let result = BFS.shortestPathInGrid(TestGrid(), from: .init(x: 0, y: 0), to: .init(x: 3, y: 0))!

		XCTAssertEqual(result.path, [
			.init(x: 0, y: 0),
			.init(x: 0, y: 1),
			.init(x: 0, y: 2),
			.init(x: 1, y: 2),
			.init(x: 2, y: 2),
			.init(x: 3, y: 2),
			.init(x: 4, y: 2),
			.init(x: 4, y: 1),
			.init(x: 4, y: 0),
			.init(x: 3, y: 0),
		])

		XCTAssertEqual(result.steps, 9)
	}
}
