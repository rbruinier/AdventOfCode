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

	private let fftHash = "fft".hashValue
	private let dacHash = "dac".hashValue

	private func countPathsIn(
		nodes: [Int: Node],
		currentNode: Int,
		endNode: Int,
		passedDAC: Bool,
		passedFFT: Bool,
		needsToPassIntermediates: Bool,
		memoization: inout [Int: Int]
	)
	-> Int {
		struct State: Hashable {
			let currentNode: Int
			let passedDAC: Bool
			let passedFFT: Bool
		}

		let stateHash = State(
			currentNode: currentNode,
			passedDAC: passedDAC,
			passedFFT: passedFFT
		).hashValue

		if let knownState = memoization[stateHash] {
			return knownState
		}

		if currentNode == endNode {
			if needsToPassIntermediates {
				return (passedDAC && passedFFT) ? 1 : 0
			} else {
				return 1
			}
		}

		let node = nodes[currentNode]!

		var sum = 0

		for output in node.outputs {
			let passedDac = passedDAC || output == dacHash
			let passedFft = passedFFT || output == fftHash

			let result = countPathsIn(
				nodes: nodes,
				currentNode: output,
				endNode: endNode,
				passedDAC: passedDac,
				passedFFT: passedFft,
				needsToPassIntermediates: needsToPassIntermediates,
				memoization: &memoization
			)

			sum += result
		}

		memoization[stateHash] = sum

		return sum
	}

	func solvePart1(withInput input: Input) -> Int {
		let startNode = "you".hashValue
		let endNode = "out".hashValue

		let nodes = input.nodes.reduce(into: [Int: Node]()) { result, node in
			result[node.id] = node
		}

		var memoization: [Int: Int] = [:]

		return countPathsIn(
			nodes: nodes,
			currentNode: startNode,
			endNode: endNode,
			passedDAC: false,
			passedFFT: false,
			needsToPassIntermediates: false,
			memoization: &memoization
		)
	}

	func solvePart2(withInput input: Input) -> Int {
		let startNode = "svr".hashValue
		let endNode = "out".hashValue

		let nodes = input.nodes.reduce(into: [Int: Node]()) { result, node in
			result[node.id] = node
		}

		var memoization: [Int: Int] = [:]

		return countPathsIn(
			nodes: nodes,
			currentNode: startNode,
			endNode: endNode,
			passedDAC: false,
			passedFFT: false,
			needsToPassIntermediates: true,
			memoization: &memoization
		)
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
