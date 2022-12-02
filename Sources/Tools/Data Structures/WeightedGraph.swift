import Foundation

public struct WeightedGraph<Element> {
    public typealias ElementIndex = Int
    public typealias Weight = Int

    public struct Edge {
        public let weight: WeightedGraph.Weight

        public let a: ElementIndex
        public let b: ElementIndex

        public var isDirectional: Bool

        public init(a: ElementIndex, b: ElementIndex, weight: Weight, isDirectional: Bool = false) {
            self.a = a
            self.b = b

            self.weight = weight

            self.isDirectional = isDirectional
        }
    }

    public let elements: [Element]

    internal let edgesByElement: [ElementIndex: [Edge]]

    public init(elements: [Element], edges: [Edge]) {
        self.elements = elements

        var edgesByElement: [ElementIndex: [Edge]] = [:]

        for edge in edges {
            edgesByElement[edge.a, default: []].append(.init(a: edge.a, b: edge.b, weight: edge.weight))

            if edge.isDirectional == false {
                edgesByElement[edge.b, default: []].append(.init(a: edge.b, b: edge.a, weight: edge.weight))
            }
        }

        self.edgesByElement = edgesByElement
    }

    internal func directionalEdges(from elementIndex: ElementIndex) -> [Edge] {
        edgesByElement[elementIndex, default: []]
    }

    public var count: Int {
        elements.count
    }
}
