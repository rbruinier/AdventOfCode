import Foundation
import Tools

/**
 Pretty clear when reading part 2 that it couldn't be brute forced but still tried anyway ;) After checking with the debugger if there was regularity with
 with intervals of arriving at an end node it was clear that each node took exactly the same number of steps to reach an end node in each cycle.

 With a previously home made LCM (least common multiple) solver you can find the number of steps when all cycles align.
 */
final class Day08Solver: DaySolver {
	let dayNumber: Int = 8

	private var input: Input!

	private struct Input {
		let instructions: [Instruction]
		let nodes: [String: LeftRight]
	}

	private enum Instruction {
		case left
		case right

		init(string: String) {
			switch string {
			case "L": self = .left
			case "R": self = .right
			default: preconditionFailure()
			}
		}
	}

	private struct LeftRight {
		let left: String
		let right: String
	}

	func solvePart1() -> Int {
		var currentInstructionIndex = 0

		var node = "AAA"
		var numberOfSteps = 0

		while true {
			defer {
				currentInstructionIndex = (currentInstructionIndex + 1) % input.instructions.count
				numberOfSteps += 1
			}

			let leftRight = input.nodes[node]!

			switch input.instructions[currentInstructionIndex] {
			case .left: node = leftRight.left
			case .right: node = leftRight.right
			}

			if node == "ZZZ" {
				break
			}
		}

		return numberOfSteps
	}

	func solvePart2() -> Int {
		var nodes: [String] = input.nodes.keys.filter { $0.hasSuffix("A") }

		var currentInstructionIndex = 0
		var numberOfSteps = 0

		var intervalPerNodeIndex: [Int: Int] = [:]

		while true {
			defer {
				currentInstructionIndex = (currentInstructionIndex + 1) % input.instructions.count
				numberOfSteps += 1
			}

			var newNodes: [String] = []

			for node in nodes {
				let leftRight = input.nodes[node]!

				switch input.instructions[currentInstructionIndex] {
				case .left: newNodes.append(leftRight.left)
				case .right: newNodes.append(leftRight.right)
				}
			}

			nodes = newNodes

			for (index, node) in nodes.enumerated() where !intervalPerNodeIndex.keys.contains(index) && node.hasSuffix("Z") {
				intervalPerNodeIndex[index] = numberOfSteps + 1
			}

			if intervalPerNodeIndex.count == nodes.count {
				break
			}
		}

		return Math.leastCommonMultiple(for: Array(intervalPerNodeIndex.values))
	}

	func parseInput(rawString: String) {
		let lines = rawString.allLines()
		var nodes: [String: LeftRight] = [:]

		let instructions: [Instruction] = lines[0].map { Instruction(string: String($0)) }

		for line in lines[1 ..< lines.count] {
			let values = line.getCapturedValues(pattern: #"([0-9A-Z]*) = \(([0-9A-Z]*), ([0-9A-Z]*)\)"#)!

			nodes[values[0]] = .init(left: values[1], right: values[2])
		}

		input = .init(instructions: instructions, nodes: nodes)
	}
}
