import Foundation
import Tools

final class Day12Solver: DaySolver {
	let dayNumber: Int = 12

	struct Input {
		let uniqueNodes: [Node]
		let startNode: Node
		let endNode: Node
	}

	private struct Path: Equatable, Hashable {
		let a: Node
		let b: Node
	}

	final class Node: CustomDebugStringConvertible, Equatable, Hashable {
		let name: String
		let isBig: Bool
		var canVisitTwice: Bool = false
		var connectedNodes: [Node]

		public var debugDescription: String {
			"\(name), connects to: [\(connectedNodes.map(\.name))]"
		}

		public init(name: String, isBig: Bool, connectedNodes: [Node]) {
			self.name = name
			self.isBig = isBig
			self.connectedNodes = connectedNodes
		}

		public static func == (lhs: Node, rhs: Node) -> Bool {
			lhs.name == rhs.name
		}

		public func hash(into hasher: inout Hasher) {
			hasher.combine(name)
		}
	}

	private func iteratePath(startNode: Node, endNode: Node) -> [[Node]] {
		var allPaths: [[Node]] = []

		var stack: [[Node]] = [[startNode]]

		while stack.isEmpty == false {
			let path = stack.popLast()!

			let lastNode = path.last!

			if lastNode == endNode {
				allPaths.append(path)

				continue
			}

			for connectingNode in lastNode.connectedNodes {
				if
					connectingNode.isBig
					|| path.contains(connectingNode) == false
					|| (connectingNode.canVisitTwice && path.filter { $0 == connectingNode }.count < 2)
				{
					stack.append(path + [connectingNode])
				}
			}
		}

		return allPaths
	}

	func solvePart1(withInput input: Input) -> Int {
		let completedPaths = iteratePath(startNode: input.startNode, endNode: input.endNode)

		return completedPaths.count
	}

	func solvePart2(withInput input: Input) -> Int {
		let smallNodes = input.uniqueNodes.filter {
			$0.isBig == false && $0 != input.startNode && $0 != input.endNode
		}

		var allPaths: Set<[Node]> = Set()

		for smallNode in smallNodes {
			smallNode.canVisitTwice = true

			let completedPaths = iteratePath(startNode: input.startNode, endNode: input.endNode)

			completedPaths.forEach {
				allPaths.insert($0)
			}

			smallNode.canVisitTwice = false
		}

		return allPaths.count
	}

	func parseInput(rawString: String) -> Input {
		let paths: [Path] = rawString
			.components(separatedBy: CharacterSet.newlines)
			.filter { $0.isEmpty == false }
			.map {
				let line = $0.components(separatedBy: "-")

				let rawA = line[0]
				let rawB = line[1]

				let a = Node(name: rawA, isBig: rawA[rawA.startIndex].isUppercase, connectedNodes: [])
				let b = Node(name: rawB, isBig: rawB[rawB.startIndex].isUppercase, connectedNodes: [])

				return Path(a: a, b: b)
			}

		let uniqueNodes = Array(Set(paths.flatMap {
			[$0.a, $0.b]
		}))

		uniqueNodes.forEach { node in
			let connectedNodes: [Node] = paths.compactMap { path in
				if path.a == node {
					return uniqueNodes.first(where: { $0.name == path.b.name })!
				} else if path.b == node {
					return uniqueNodes.first(where: { $0.name == path.a.name })!
				}

				return nil
			}

			node.connectedNodes = connectedNodes
		}

		let startNode = uniqueNodes.first(where: { $0.name == "start" })!
		let endNode = uniqueNodes.first(where: { $0.name == "end" })!

		return .init(uniqueNodes: uniqueNodes, startNode: startNode, endNode: endNode)
	}
}
