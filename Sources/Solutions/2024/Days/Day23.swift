import Foundation
import Tools

final class Day23Solver: DaySolver {
	let dayNumber: Int = 23

	struct Input {
		let connections: [String: Set<String>]
	}

	/// https://en.wikipedia.org/wiki/Bron%E2%80%93Kerbosch_algorithm
	private func solveWithBronKerbosch(r: Set<String>, p: Set<String>, x: Set<String>, allConnections: [String: Set<String>], cliques: inout [Set<String>]) {
		if p.isEmpty, x.isEmpty {
			cliques.append(r)

			return
		}

		var currentP = p
		var currentX = x

		for v in p {
			let neighbors = allConnections[v]!

			solveWithBronKerbosch(
				r: r.union([v]),
				p: currentP.intersection(neighbors),
				x: currentX.intersection(neighbors),
				allConnections: allConnections,
				cliques: &cliques
			)

			currentP.remove(v)
			currentX.insert(v)
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		var allConnections = input.connections

		for (key, subSet) in allConnections {
			for node in subSet {
				allConnections[node, default: []].insert(key)
			}
		}

		// brute force all the things
		var groups: Set<Set<String>> = []

		for (aNode, aConnections) in allConnections {
			for bNode in aConnections {
				let bConnections = allConnections[bNode]!

				for cNode in bConnections {
					let cConnections = allConnections[cNode]!

					if cConnections.contains(aNode) {

						if aNode.starts(with: "t") || bNode.starts(with: "t") || cNode.starts(with: "t") {
							groups.insert([aNode, bNode, cNode])
						}
					}
				}
			}
		}

		return groups.count
	}

	func solvePart2(withInput input: Input) -> String {
		var allConnections = input.connections

		for (key, subSet) in allConnections {
			for node in subSet {
				allConnections[node, default: []].insert(key)
			}
		}

		var cliques: [Set<String>] = []

		solveWithBronKerbosch(r: [], p: Set(allConnections.keys), x: [], allConnections: allConnections, cliques: &cliques)

		guard let biggestClique = cliques.sorted(by: { $0.count > $1.count }).first else {
			preconditionFailure()
		}

		return biggestClique.sorted().joined(separator: ",")
	}

	func parseInput(rawString: String) -> Input {
		var connections: [String: Set<String>] = [:]

		for line in rawString.allLines() {
			let componenents = line.components(separatedBy: "-")

			connections[componenents[0], default: []].insert(componenents[1])
		}

		return .init(connections: connections)
	}
}
