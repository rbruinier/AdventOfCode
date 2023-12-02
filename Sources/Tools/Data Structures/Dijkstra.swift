public enum Dijkstra {}

public extension Dijkstra {
	struct ShortestPathInWeightedGraphResult {
		/// The full path from point A to point B.
		public let pathIndices: [WeightedGraph.ElementIndex]

		public let weight: Int
	}

	struct ShortestPathInUnweightedGraphResult {
		/// The full path from point A to point B.
		public let pathIndices: [UnweightedGraph.ElementIndex]

		/// The total number of steps required to get from point A to point B in the grid.
		public var steps: Int {
			pathIndices.count - 1
		}
	}

	private struct PathSegment {
		let a: WeightedGraph.ElementIndex
		let b: WeightedGraph.ElementIndex

		let weight: WeightedGraph.Weight

		let combinedWeight: WeightedGraph.Weight
	}

	private struct Node: Comparable {
		let index: WeightedGraph.ElementIndex
		let weight: WeightedGraph.Weight

		static func < (lhs: Node, rhs: Node) -> Bool {
			lhs.weight < rhs.weight
		}
	}

	static func shortestPathInGraph(_ graph: WeightedGraph, from a: Int, to b: Int) -> ShortestPathInWeightedGraphResult? {
		var weights: [WeightedGraph.Weight?] = .init(repeating: nil, count: graph.count)
		var pathsByIndex: [WeightedGraph.ElementIndex: PathSegment] = [:]

		weights[a] = 0

		var priorityQueue = PriorityQueue<Node>(isAscending: true)

		priorityQueue.push(.init(index: a, weight: 0))

		queueLoop: while let node = priorityQueue.pop() {
			guard let weight = weights[node.index] else {
				preconditionFailure()
			}

			if node.index == b {
				break queueLoop
			}

			for edge in graph.directionalEdges(from: node.index) {
				let oldWeight = weights[edge.b]

				let combinedWeight = edge.weight + weight

				if oldWeight == nil || combinedWeight < oldWeight! {
					weights[edge.b] = combinedWeight
					pathsByIndex[edge.b] = .init(a: edge.a, b: edge.b, weight: edge.weight, combinedWeight: combinedWeight)

					priorityQueue.push(.init(index: edge.b, weight: combinedWeight))
				}
			}
		}

		let lastSegment = pathsByIndex.values.first { $0.b == b }!

		var path: [PathSegment] = []

		var currentIndex = lastSegment.b

		while let pathSegment = pathsByIndex.values.first(where: { $0.b == currentIndex }) {
			path.append(pathSegment)

			currentIndex = pathSegment.a
		}

		path.reverse()

		return .init(
			pathIndices: [a] + path.map(\.b),
			weight: lastSegment.combinedWeight
		)
	}

	static func shortestPathInGraph(_ graph: UnweightedGraph, from a: Int, to b: Int) -> ShortestPathInUnweightedGraphResult? {
		var weights: [WeightedGraph.Weight?] = .init(repeating: nil, count: graph.count)
		var pathsByIndex: [WeightedGraph.ElementIndex: PathSegment] = [:]

		weights[a] = 0

		var priorityQueue = PriorityQueue<Node>(isAscending: true)

		priorityQueue.push(.init(index: a, weight: 0))

		queueLoop: while let node = priorityQueue.pop() {
			guard let weight = weights[node.index] else {
				preconditionFailure()
			}

			if node.index == b {
				break queueLoop
			}

			for edge in graph.directionalEdges(from: node.index) {
				let oldWeight = weights[edge.b]

				let combinedWeight = 1 + weight

				if oldWeight == nil || combinedWeight < oldWeight! {
					weights[edge.b] = combinedWeight
					pathsByIndex[edge.b] = .init(a: edge.a, b: edge.b, weight: 1, combinedWeight: combinedWeight)

					priorityQueue.push(.init(index: edge.b, weight: combinedWeight))
				}
			}
		}

		let lastSegment = pathsByIndex.values.first { $0.b == b }!

		var path: [PathSegment] = []

		var currentIndex = lastSegment.b

		while let pathSegment = pathsByIndex.values.first(where: { $0.b == currentIndex }) {
			path.append(pathSegment)

			currentIndex = pathSegment.a
		}

		path.reverse()

		return .init(
			pathIndices: [a] + path.map(\.b)
		)
	}
}
