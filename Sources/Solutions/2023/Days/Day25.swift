import Foundation
import Tools

final class Day25Solver: DaySolver {
	let dayNumber: Int = 25

	private var input: Input!

	private typealias Nodes = [String: Set<String>]

	private struct Input {
		let nodes: Nodes
	}

	func solvePart1() -> Int {
		var edges: [KargerMinimumCut.Edge] = []

		let nodeAsArray = Array(input.nodes.keys)

		for (a, targetNodes) in input.nodes {
			let aIndex = nodeAsArray.firstIndex(of: a)!

			for b in targetNodes {
				let bIndex = nodeAsArray.firstIndex(of: b)!

				edges.append(.init(a: aIndex, b: bIndex))
			}
		}

		let graph = KargerMinimumCut.Graph(numberOfNodes: nodeAsArray.count, edges: edges)

		while true {
			let result = KargerMinimumCut.solve(for: graph)

			if result.numberOfCuts == 3 {
				return result.subsetA.count * result.subsetB.count
			}
		}
	}

	func solvePart2() -> String {
		"Merry Christmas 🎄"
	}

	func parseInput(rawString: String) {
		var nodes: [String: Set<String>] = [:]

		rawString.allLines().forEach { line in
			let components = line.components(separatedBy: ": ")

			nodes[components[0]] = Set(components[1].components(separatedBy: " "))
		}

		// make them unique so we don't have double edges as the graph is undirected anyway
		for (a, targetNodes) in nodes {
			for b in targetNodes {
				if nodes[b] == nil {
					nodes[b] = []
				} else if nodes[b]?.contains(a) ?? false {
					nodes[b]!.remove(a)
				}
			}
		}

		input = .init(nodes: nodes)
	}
}
