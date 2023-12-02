import Foundation

public struct UnweightedGraph {
	public typealias ElementIndex = Int

	public struct Edge: Equatable, Hashable {
		public let a: ElementIndex
		public let b: ElementIndex

		public var isDirectional: Bool

		public init(a: ElementIndex, b: ElementIndex, isDirectional: Bool = false) {
			self.a = a
			self.b = b

			self.isDirectional = isDirectional
		}
	}

	let elementsCount: Int
	let edgesByElement: [ElementIndex: [Edge]]

	public init(elementsCount: Int, edges: [Edge]) {
		self.elementsCount = elementsCount

		var edgesByElement: [ElementIndex: [Edge]] = [:]

		for edge in edges {
			edgesByElement[edge.a, default: []].append(.init(a: edge.a, b: edge.b))

			if edge.isDirectional == false {
				edgesByElement[edge.b, default: []].append(.init(a: edge.b, b: edge.a))
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
