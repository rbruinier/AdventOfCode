import Foundation
import Tools

final class Day06Solver: DaySolver {
	let dayNumber: Int = 6

	private var input: Input!

	private struct Input {
		let orbits: [String: Node]
	}

	private final class Node {
		var id: String
		var parent: Node?
		var children: [Node] = []

		init(id: String) {
			self.id = id
		}
	}

	private func orbitsFor(node: Node) -> (direct: Int, indirect: Int) {
		guard node.children.isNotEmpty else {
			return (direct: 0, indirect: 0)
		}

		var result: (direct: Int, indirect: Int) = (direct: node.children.count, indirect: 0)

		for childNode in node.children {
			let orbitResult = orbitsFor(node: childNode)

			result.indirect += orbitResult.direct + orbitResult.indirect
		}

		return result
	}

	private func pathTo(objectID: String, allOrbits: [String: Node]) -> [String] {
		var currentNode = allOrbits[objectID]!

		var path: [String] = []
		while true {
			path.insert(currentNode.id, at: 0)

			if let parentNode = currentNode.parent {
				currentNode = parentNode
			} else {
				break
			}
		}

		return path
	}

	func solvePart1() -> Int {
		var result = 0

		for node in input.orbits.values {
			let orbitResult = orbitsFor(node: node)

			result += orbitResult.direct + orbitResult.indirect
		}

		return result
	}

	func solvePart2() -> Int {
		let allOrbits = input.orbits

		let pathToSan = pathTo(objectID: "SAN", allOrbits: allOrbits)
		let pathToYou = pathTo(objectID: "YOU", allOrbits: allOrbits)

		for index in 0 ..< min(pathToSan.count, pathToYou.count) {
			if pathToSan[index] == pathToYou[index] {
				continue
			}

			return (pathToSan.count - index) + (pathToYou.count - index) - 2
		}

		return 0
	}

	func parseInput(rawString: String) {
		var nodes: [String: Node] = [:]

		rawString.allLines().forEach {
			let components = $0.components(separatedBy: ")")

			let parentNode = nodes[components[0], default: Node(id: components[0])]
			let childNode = nodes[components[1], default: Node(id: components[1])]

			parentNode.children.append(childNode)
			childNode.parent = parentNode

			nodes[components[0]] = parentNode
			nodes[components[1]] = childNode
		}

		input = .init(orbits: nodes)
	}
}
