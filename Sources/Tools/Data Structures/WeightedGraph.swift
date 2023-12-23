import Foundation

public struct WeightedGraph {
	public typealias ElementIndex = Int
	public typealias Weight = Int

	public struct Edge: Equatable, Hashable {
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

	public let edgesByElement: [ElementIndex: Set<Edge>]
	public let elementsCount: Int

	public init(elementsCount: Int, edges: [Edge]) {
		self.elementsCount = elementsCount

		var edgesByElement: [ElementIndex: Set<Edge>] = [:]

		for edge in edges {
			edgesByElement[edge.a, default: []].insert(.init(a: edge.a, b: edge.b, weight: edge.weight))

			if edge.isDirectional == false {
				edgesByElement[edge.b, default: []].insert(.init(a: edge.b, b: edge.a, weight: edge.weight))
			}
		}

		self.edgesByElement = edgesByElement
	}

	func directionalEdges(from elementIndex: ElementIndex) -> Set<Edge> {
		edgesByElement[elementIndex, default: .init()]
	}

	public var count: Int {
		elementsCount
	}
}
