import Foundation
import Tools

final class Day11Solver: DaySolver {
	let dayNumber: Int = 11

	private var input: Input!

	struct Node {
		let id: Int
		let outputs: Set<Int>
	}

	struct Input {
		let nodes: [Node]
	}

	private func countPathsIn(nodes: [Int: Node], currentNode: Int, endNode: Int, memoization: inout [Int: Int]) -> Int {
		let stateHash = currentNode.hashValue

		if let knownState = memoization[stateHash] {
			return knownState
		}

		if currentNode == endNode {
			return 1
		}

		guard let node = nodes[currentNode] else {
			return 0
		}

		var sum = 0

		for output in node.outputs {
			let result = countPathsIn(
				nodes: nodes,
				currentNode: output,
				endNode: endNode,
				memoization: &memoization
			)

			sum += result
		}

		memoization[stateHash] = sum

		return sum
	}

	private func solveRoute(with path: [String], nodes: [Int: Node]) -> Int {
		var memoization: [Int: Int] = [:]

		var result = 1

		for i in 0 ..< path.count - 1 {
			memoization.removeAll()

			let a = path[i]
			let b = path[i + 1]

			result *= countPathsIn(nodes: nodes, currentNode: a.hashValue, endNode: b.hashValue, memoization: &memoization)
		}

		return result
	}

	func solvePart1(withInput input: Input) -> Int {
		let startNode = "you"
		let endNode = "out"

		let nodes = input.nodes.reduce(into: [Int: Node]()) { result, node in
			result[node.id] = node
		}

		return solveRoute(with: [startNode, endNode], nodes: nodes)
	}

	func solvePart2(withInput input: Input) -> Int {
		let startNode = "svr"
		let endNode = "out"

		let stop1 = "fft"
		let stop2 = "dac"

		let nodes = input.nodes.reduce(into: [Int: Node]()) { result, node in
			result[node.id] = node
		}

		let r1 = solveRoute(with: [startNode, stop1, stop2, endNode], nodes: nodes)
		let r2 = solveRoute(with: [startNode, stop2, stop1, endNode], nodes: nodes)

		return r1 + r2
	}

	func parseInput(rawString: String) -> Input {
		.init(nodes: rawString.allLines().map { line in
			let components = line.components(separatedBy: ": ")

			let id = components[0]
			let outputs = components[1].components(separatedBy: " ").map(\.hashValue)

			return Node(id: id.hashValue, outputs: Set(outputs))
		})
	}
}
