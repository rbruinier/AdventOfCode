import Foundation

/// Based on Source: https://www.geeksforgeeks.org/introduction-and-implementation-of-kargers-algorithm-for-minimum-cut/
public enum KargerMinimumCut {
	public struct Edge {
		public let a: Int
		public let b: Int

		public init(a: Int, b: Int) {
			self.a = a
			self.b = b
		}
	}

	public struct Graph {
		public let numberOfNodes: Int
		public let edges: [Edge]

		public init(numberOfNodes: Int, edges: [Edge]) {
			self.numberOfNodes = numberOfNodes
			self.edges = edges
		}
	}

	private final class Subset {
		var parent: Int
		var rank: Int

		init(parent: Int, rank: Int) {
			self.parent = parent
			self.rank = rank
		}
	}

	/// As this algorithm is based on randomness make sure to run it multiple times to get better results.
	public static func solve(for graph: Graph) -> (numberOfCuts: Int, subsetA: Set<Int>, subsetB: Set<Int>) {
		let subsets: [Subset] = (0 ..< graph.numberOfNodes).map { .init(parent: $0, rank: 0) }

		var numberOfVerticesRemaining = graph.numberOfNodes

		while numberOfVerticesRemaining > 2 {
			let i = Int(arc4random()) % graph.edges.count

			let subset1 = find(subsets: subsets, i: graph.edges[i].a)
			let subset2 = find(subsets: subsets, i: graph.edges[i].b)

			if subset1 != subset2 {
				numberOfVerticesRemaining -= 1

				union(subsets: subsets, x: subset1, y: subset2)
			}
		}

		var numberOfCuts = 0
		for i in 0 ..< graph.edges.count {
			let subset1 = find(subsets: subsets, i: graph.edges[i].a)
			let subset2 = find(subsets: subsets, i: graph.edges[i].b)

			if subset1 != subset2 {
				numberOfCuts += 1
			}
		}

		var finalSubsets: [Int: Set<Int>] = [:]

		for v in 0 ..< graph.numberOfNodes {
			let s = find(subsets: subsets, i: v)

			finalSubsets[s, default: []].insert(v)
		}

		return (numberOfCuts: numberOfCuts, subsetA: Array(finalSubsets.values)[0], subsetB: Array(finalSubsets.values)[1])
	}

	private static func find(subsets: [Subset], i: Int) -> Int {
		if subsets[i].parent != i {
			subsets[i].parent = find(subsets: subsets, i: subsets[i].parent)
		}

		return subsets[i].parent
	}

	private static func union(subsets: [Subset], x: Int, y: Int) {
		let xroot = find(subsets: subsets, i: x)
		let yroot = find(subsets: subsets, i: y)

		if subsets[xroot].rank < subsets[yroot].rank {
			subsets[xroot].parent = yroot
		} else if subsets[xroot].rank > subsets[yroot].rank {
			subsets[yroot].parent = xroot
		} else {
			subsets[yroot].parent = xroot
			subsets[xroot].rank += 1
		}
	}
}
