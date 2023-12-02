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

	let edgesByElement: [ElementIndex: [Edge]]
	let elementsCount: Int

	public init(elementsCount: Int, edges: [Edge]) {
		self.elementsCount = elementsCount

		var edgesByElement: [ElementIndex: [Edge]] = [:]

		for edge in edges {
			edgesByElement[edge.a, default: []].append(.init(a: edge.a, b: edge.b, weight: edge.weight))

			if edge.isDirectional == false {
				edgesByElement[edge.b, default: []].append(.init(a: edge.b, b: edge.a, weight: edge.weight))
			}
		}

		self.edgesByElement = edgesByElement
	}

	func directionalEdges(from elementIndex: ElementIndex) -> [Edge] {
		edgesByElement[elementIndex, default: []]
	}

	public var count: Int {
		elementsCount
	}
}
