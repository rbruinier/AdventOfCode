// import Foundation
// import Tools
// import XCTest
//
// final class DijkstraTests: XCTestCase {
//    //	func testStraighforwardShortestDistance() {
//    //		let items: [String] = ["A", "B", "C", "D"]
////
//    //		let graph = WeightedGraph(elements: items, edges: [
//    //			.init(a: 0, b: 1, weight: 10), // A - B = 30
//    //			.init(a: 0, b: 2, weight: 60), // A - C = 20
//    //			.init(a: 0, b: 3, weight: 60), // A - D = 10
//    //			.init(a: 1, b: 2, weight: 10), // B - C = 20
//    //			.init(a: 1, b: 3, weight: 60), // B - D = 30
//    //			.init(a: 2, b: 3, weight: 10), // C - D = 10
//    //		])
////
//    //		let sut = Dijkstra(graph: graph)
////
//    //		let result = sut.visitAllElements()
////
//    //		print(result)
//    //	}
//
//    func testIdenticalWeightsShortestDistance() {
//        let items: [String] = ["A", "B", "C", "D"]
//
//		let graph = WeightedGraph(elementsCount: items.count, edges: [
//            .init(a: 0, b: 1, weight: 10), // A - B = 10
//            .init(a: 0, b: 2, weight: 10), // A - C = 10
//            .init(a: 0, b: 3, weight: 10), // A - D = 10
//            .init(a: 1, b: 2, weight: 10), // B - C = 10
//            .init(a: 1, b: 3, weight: 10), // B - D = 20
//            .init(a: 2, b: 3, weight: 10) // C - D = 30
//        ])
//
//        let sut = Dijkstra(graph: graph)
//
//        let result = sut.visitAllElements()
//
//        print(result)
//    }
// }
