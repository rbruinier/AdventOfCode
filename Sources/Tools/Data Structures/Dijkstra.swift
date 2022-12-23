// import Foundation
//
// public struct Dijkstra<Element> {
//    private struct Node: Comparable {
//        let index: Int
//        let weight: Int
//
//        static func < (lhs: Node, rhs: Node) -> Bool {
//            lhs.weight < rhs.weight
//        }
//    }
//
//    public struct Result {
//        let path: [PathSegment]
//        let pathIndices: [Int]
//        let visitedElements: [Element]
//
//        var combinedWeight: Int {
//            path.last!.combinedWeight
//        }
//    }
//
//    public struct PathSegment {
//        let a: WeightedGraph.ElementIndex
//        let b: WeightedGraph.ElementIndex
//
//        let weight: WeightedGraph.Weight
//
//        let combinedWeight: WeightedGraph.Weight
//    }
//
//    public let graph: WeightedGraph<Element>
//
//    public init(graph: WeightedGraph<Element>) {
//        self.graph = graph
//    }
//
//    public func visitAllElements(startingAt rootIndex: Int = 0) -> Result {
//        var weights: [WeightedGraph.Weight?] = Array(repeating: nil, count: graph.count)
//        var pathsByIndex: [WeightedGraph.ElementIndex: PathSegment] = [:]
//
//        weights[rootIndex] = 0
//
//        var priorityQueue = PriorityQueue<Node>(isAscending: true)
//
//        priorityQueue.push(.init(index: rootIndex, weight: 0))
//
//        while let node = priorityQueue.pop() {
//            guard let weight = weights[node.index] else {
//                fatalError()
//            }
//
//            for edge in graph.directionalEdges(from: node.index) {
//                let oldWeight = weights[edge.b]
//
//                let combinedWeight = edge.weight + weight
//
//                if oldWeight == nil || combinedWeight < oldWeight! {
//                    weights[edge.b] = combinedWeight
//                    pathsByIndex[edge.b] = .init(a: edge.a, b: edge.b, weight: edge.weight, combinedWeight: combinedWeight)
//
//                    priorityQueue.push(.init(index: edge.b, weight: combinedWeight))
//                }
//            }
//        }
//
//        let maxCombinedWeight = pathsByIndex.map(\.value.combinedWeight).max()!
//
//        let lastSegment = pathsByIndex.values.first(where: { $0.combinedWeight == maxCombinedWeight })!
//
//        var path: [PathSegment] = []
//
//        var currentIndex = lastSegment.b
//
//        while let pathSegment = pathsByIndex.values.first(where: { $0.b == currentIndex }) {
//            path.append(pathSegment)
//
//            currentIndex = pathSegment.a
//        }
//
//        path.reverse()
//
//        return .init(
//            path: path,
//            pathIndices: [rootIndex] + path.map(\.b),
//            visitedElements: [graph.elements[rootIndex]] + path.map { graph.elements[$0.b] }
//        )
//    }
// }
