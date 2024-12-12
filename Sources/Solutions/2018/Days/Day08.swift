import Foundation
import Tools

final class Day08Solver: DaySolver {
	let dayNumber: Int = 8

	private var input: Input!

	private struct Input {
		let node: Node
	}

	private final class Node {
		var childNodes: [Node] = []
		var metadataEntries: [Int] = []

		init() {}
	}

	private func sumOfMetadata(node: Node) -> Int {
		node.metadataEntries.reduce(0, +) + node.childNodes.reduce(0) { $0 + sumOfMetadata(node: $1) }
	}

	private func valueOf(node: Node) -> Int {
		if node.childNodes.isEmpty {
			node.metadataEntries.reduce(0, +)
		} else {
			node.metadataEntries.reduce(into: 0) { result, nodeID in
				if let childNode = node.childNodes[safe: nodeID - 1] {
					result += valueOf(node: childNode)
				}
			}
		}
	}

	func solvePart1() -> Int {
		sumOfMetadata(node: input.node)
	}

	func solvePart2() -> Int {
		valueOf(node: input.node)
	}

	func parseInput(rawString: String) {
		func parseNode(at position: inout Int, data: [Int]) -> Node {
			let node = Node()

			let numberOfChildNodes = data[position]

			position += 1

			let numberOfMetadataEntries = data[position]

			position += 1

			for _ in 0 ..< numberOfChildNodes {
				node.childNodes.append(parseNode(at: &position, data: data))
			}

			for _ in 0 ..< numberOfMetadataEntries {
				node.metadataEntries.append(data[position])

				position += 1
			}

			return node
		}

		var position = 0

		input = .init(node: parseNode(at: &position, data: rawString.allLines().first!.components(separatedBy: " ").map { Int($0)! }))
	}
}
